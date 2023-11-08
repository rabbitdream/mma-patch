# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""The Python implementation of the GRPC helloworld.Greeter server."""

import sys
import os

work_dir =os.getcwd()
sys.path.append(work_dir)
sys.path.append(work_dir+"/faceproto/")
# sys.path.append(work_dir+"/facenet/src/")
sys.path.append(work_dir+"/facenet/")
sys.path.append(work_dir+"/facenet/align")

from concurrent import futures
import time

import grpc

from faceproto import faceproto_pb2,faceproto_pb2_grpc
from log  import log_init
import logging

print("import argparse")

import argparse
import tensorflow as tf
import numpy as np
# import facenet
from log import log_init
import logging
# import align.detect_face
import random
from time import sleep
from io import BytesIO 
# from PIL import Image, ImageFilter
import imageio
from scipy import misc
# from myface.mtcnn_facenet import detectface,facenet_ebeding,myclassify,myclassify2,TvuFace
# from mtcnn_facenet import detectface,facenet_ebeding,myclassify,myclassify2,TvuFace
print("import TvuFace")
from mtcnn_facenet import TvuFace
# from classifier import NeurosFaceClassifier,NeurosFaceClassifierStd
print("import knn")
from sklearn.neighbors import KNeighborsClassifier 

import threading
import gc
# import string
import psutil
import json
_ONE_DAY_IN_SECONDS = 60 * 60 * 24
print("import end")





def protectFun():
    p1=psutil.Process(os.getpid())
    m = p1.memory_percent()
    allmem = psutil.virtual_memory()
    allUsePercent = allmem.percent
    allAvailable = allmem.available/1024/1024
    logging.info("m={},allUsePercent={},allAvailable={}".format(m,allUsePercent,allAvailable))
    # if m > 40 or allAvailable < 500:
    if m > 40:
        logging.error("stop gServer:begin")
        gServer.stop(0)
        logging.error("stop gServer:grpc")
        os._exit(1)

def timer():
    while True:
        logging.info("enter")
        time.sleep(60)
        protectFun()
def embed_performance_test():
    logging.debug("enter")
    faceEmd = facenet_ebeding(work_dir+"/../sailingzhang/embed_model")
    img_list = []
    for dirpath, dirnames, filenames in os.walk(work_dir+"/../tmp/ml_pic/to_compare"):
        for filename in filenames:
            fullname = os.path.join(dirpath, filename)
            img_list.append(fullname)

    for it in range(5):
        logging.debug("test begin")    
        embs=faceEmd.embed_paths(img_list[it:it+1])
        # logging.debug("len(embs)={}".format(len(embs)))
        logging.debug("begin compare")
        for i in range(10):
            print("\n{} ".format(i),end='')
            for j in range(10):
                dist = np.sqrt(np.sum(np.square(np.subtract(embs[0,:], embs[0,:]))))
                print('  %1.4f  ' % dist, end='')
        logging.debug("test end")  

# model = NeurosFaceClassifierStd(6000,1)
class FaceGreeter(faceproto_pb2_grpc.FaceIdentyServicer):
    def __init__(self):
        logging.debug("init begin")
        self.lock = threading.Lock()
        ##############################################
        model = KNeighborsClassifier(n_neighbors=1)
        datadir = sys.argv[2]
        logging.debug("datadir={},type(datadir)={},len(datadir)={}".format(datadir,type(datadir),len(datadir)))
        self.tvuface = TvuFace(work_dir,datadir,model)
        # self.tvuface.fit()
        ##############################################
        self.embedFaceNum = 0
        self.embedFaceMaxLimitNum = 2000
        logging.debug("init end")
        ####################################################
        self.lastTrainOkTime =0
        # self.createPersonTimeMap = {}
        self.localpersonMap=None
        self.localpersonMapFile = "localpersonmap.json"
        self.jsonfileLock =  threading.Lock()
        while self.localpersonMap is None:
            if os.path.exists(self.localpersonMapFile)==True:
                with open(self.localpersonMapFile,'r') as file:
                    self.localpersonMap = json.load(file)
            else:
                self.localpersonMap={}
            logging.info("init localpersonMap={}".format(self.localpersonMap))


    def _predect_map(self,string_id,detMap):
        rsp = faceproto_pb2.PredictRsp()
        rsp.id = string_id
        faceindex = 0
        with self.lock:
            # self._clearPersonByTime(self.lastTrainOkTime)
            self._clearPersonByTime2(self.lastTrainOkTime)
            for obj in detMap.values():
                faceindex+=1
                faceojb= obj[1]
                facebox =obj[0]
                predictList = self.tvuface.predict([faceojb.emb])
                faceid = faceojb.faceid
                logging.debug("predictList={},faceid={},obj={}".format(predictList,faceid,obj))
                addface = rsp.predictFaces.add()
                addface.faceid = faceid
                addface.left = facebox[0]
                addface.top = facebox[1]
                addface.width = facebox[2]
                addface.height = facebox[3]
                predict = predictList[0]            
                if predict is None:
                    logging.debug("faceid={} no predict,begin addperson".format(faceid))
                    addpersonid = "P-"+str(faceindex)+"-"+string_id
                    logging.debug("no predict ,addpersonid={}".format(addpersonid))
                    self.tvuface.addFaceToPerson(addpersonid,faceojb.faceid,faceojb.alingned_pic,faceojb.emb)
                    self.tvuface.fit()
                    addface.personid = addpersonid
                    addface.newperson = True
                    addface.confidence = 0
                    # self.createPersonTimeMap[string_id] = addpersonid
                    logging.info("new_personid={},addfaceid={},width={},height={},personsize={},facesize={}".format(addpersonid,obj[1].faceid,addface.width,addface.height,self.tvuface.PersonSize(),self.tvuface.FaceSize()))
                else:
                    personid = predict[0]
                    dist = predict[2]
                    addface.personid = personid
                    addface.newperson = False
                    addface.confidence = dist
                    logging.info("old_personid={},faceid={},width={},height={},personsize={},facesize={}".format(personid,faceid,addface.width,addface.height,self.tvuface.PersonSize(),self.tvuface.FaceSize()))
                    self.tvuface.addFaceToPerson(personid,faceojb.faceid,faceojb.alingned_pic,faceojb.emb)
                    self.tvuface.fit()
            logging.debug("normal,exit")
            return rsp
    def _initFace(self):
        logging.info("enter")
        with self.lock:
            self.tvuface.clear(KNeighborsClassifier(n_neighbors=1))
            logging.debug("exit")
        gc.collect()

    def _clearPersonByTime(self,time):
        logging.info("time={}".format(time))
        isfit = False
        keyslist = list(self.createPersonTimeMap.keys())
        for key in keyslist:
            keytime =int(key)
            logging.info("keytime={},time={}".format(keytime,time))
            if keytime < time:
                localpersonid=self.createPersonTimeMap[key]
                logging.info("begin del personbytiem,time={},personcreatetime={},localpersonid={}".format(time,keytime,localpersonid))
                self.tvuface.delPerson(localpersonid)
                self.createPersonTimeMap.pop(key,None)
                self.localpersonMap.pop(localpersonid,None)
                isfit = True
        if True == isfit:
            self.tvuface.fit()
    def _clearPersonByTime2(self,time):
        logging.info("time={}".format(time))
        isfit = False
        personids = self.tvuface.GetAllPersonids()
        logging.debug("personids={}".format(personids))
        for personid in personids:
            if len(personid) < 13:
                continue
            createTime = int(personid[-13:])
            logging.debug("dataset personid={},ctime={}".format(personid,createTime))
            if createTime < time:
                self.tvuface.delPerson(personid)
                logging.info("del from dataset personid={}".format(personid))
                isfit = True
        if self.localpersonMap is not None:
            for v in self.localpersonMap.values():  
                personids = list(v.keys())
                for personid in personids:
                    if len(personid) < 13:
                        continue
                    createTime = int(personid[-13:])
                    logging.debug("localpersonmap personid={},ctime={}".format(personid,createTime))
                    if createTime < time:
                        logging.info("del from localpersonMap,personid={}".format(personid))
                        v.pop(personid,None)
        if True == isfit:
            self.tvuface.fit()

    def InitFace(self,request,context):
        logging.info("enter,bclear={}".format(request.bclear))
        if request.bclear:
            with self.lock:
                self.tvuface.clear(KNeighborsClassifier(n_neighbors=1))
                logging.debug("exit")
            self._initFace()
        else:
            self.tvuface.clearDetectCount()
        return faceproto_pb2.InitFaceRsp(error=0,error_message="no error")
    def FindSimilarHistoryFace(self,request,context):
        logging.debug("enter,facenum={}".format(len(request.faces)))
        imgList=[]
        idList =[]
        rsp = faceproto_pb2.FindSimilarFaceRsp()
        threshold = request.threshold
        peerid = request.peerId
        faces  = request.faces
        if 0 == len(faces):
            logging.info("timestamp={},face number is 0".format(request.timestamp))
            return rsp
        for face in faces:
            logging.debug("peerid={},threshold={},face.Id={}".format(peerid,threshold,face.Id))
            image =imageio.imread(face.facePic)
            imgList.append(image)
            idList.append(face.Id)
        dectMap = self.tvuface.detectAlinedImgs(idList,imgList,request.timestamp)

        rsp = self._predect_map(str(request.timestamp),dectMap)

        # if self.tvuface.FaceSize() > self.embedFaceMaxLimitNum:
        #     logging.info("facenumber limit,maxlimitnum={}".format(self.embedFaceMaxLimitNum))
        #     self._initFace()

        return rsp
        

    def Detect(self,request,context):
        logging.debug("enter")
        rsp = faceproto_pb2.PredictRsp()
        rsp.id = request.id
        if 0 == len(request.pic):
            logging.debug("pic is 0,exit")
            return rsp
        image =imageio.imread(request.pic)
        faceMinSize =100
        logging.debug("begin detectImg,faceMinSize={},misc'shape={}".format(faceMinSize,image.shape))
        dectMap = self.tvuface.detectImg(request.id,image,max(faceMinSize,20))
        logging.debug("detMap={}".format(dectMap))
        if not dectMap:
            logging.debug("empty detmap,exit")
            return rsp
        
        faceindex =0
        for obj in dectMap.values():
            faceindex+=1
            faceojb= obj[1]
            facebox =obj[0]
            addface = rsp.predictFaces.add()
            addface.faceid = faceojb.faceid
            addface.left = facebox[0]
            addface.top = facebox[1]
            addface.width = facebox[2]
            addface.height = facebox[3]
        return rsp

    def Predict(self,request,context):
        logging.debug("enter")
        rsp = faceproto_pb2.PredictRsp()
        rsp.id = request.id
        if 0 == len(request.pic):
            logging.debug("pic is 0,exit")
            return rsp
        image =imageio.imread(request.pic)
        faceMinSize =min(image.shape[1],image.shape[0])//20
        logging.debug("begin detectImg,faceMinSize={},image'shape={}".format(faceMinSize,image.shape))
        dectMap = self.tvuface.detectImgAndEmbed(request.id,image,max(faceMinSize,20))
        logging.debug("detMap={}".format(dectMap))
        if not dectMap:
            logging.debug("empty detmap,exit")
            return rsp

        rsp = self._predect_map(request.id,dectMap)


        # if self.tvuface.FaceSize() > self.embedFaceMaxLimitNum:
        #     logging.info("facenumber limit,maxlimitnum={}".format(self.embedFaceMaxLimitNum))
        #     self._initFace()
        return rsp
    def Stop(self,request,context):
        logging.info("stop,peerid={}".format(request))
        rsp = faceproto_pb2.StopRsp()
        return rsp
    
    def SetPersonIdRelation(self,request,context):
        logging.debug("enter")
        rsp =faceproto_pb2.SetPeronIdRelationRsp()
        with self.jsonfileLock:
            groupid = request.groupId
            self.lastTrainOkTime = request.trainOkTime
            personmap =self.localpersonMap.get(groupid,{})
            logging.info("begin set groupid={},lastTrainOkTime={},pairs={}".format(groupid,self.lastTrainOkTime,request.pairs))
            for v in request.pairs:
                if personmap.get(v.localPersonId,None) is None:
                    personmap[v.localPersonId] = v.msPersonId
                    logging.info("set personmap,localpersonid={},mspersonid={}".format(v.localPersonId,v.msPersonId))
                else:
                    logging.error("the relation have seted,localpersonid={},mspersonid={}".format(v.localPersonId,v.msPersonId))
            self.localpersonMap[groupid] = personmap
            with open(self.localpersonMapFile,'w') as file:
                json.dump(self.localpersonMap,file)
            logging.info("SetPeronIdRelation ok,req={}".format(request))
            return rsp
    def GetPersonIdRelation(self,request,context):
        logging.debug("enter")
        rsp = faceproto_pb2.GetPersonIdRelationRsp()
        with self.jsonfileLock:
            groupid = request.groupId
            logging.info("groupid={}".format(groupid))
            personMap = self.localpersonMap.get(groupid,None)
            if personMap is None:
                logging.info("personMap no find groupid={}".format(groupid))
                rsp.rspinfo = "no such group"
                return rsp
            if 0 == len(request.localPersonIds):
                logging.info("get all personidmap")
                for localpersonid,mspersonid in personMap.items():
                    rsp.relationmap[localpersonid] = mspersonid
            else:
                for localpersonid in request.localPersonIds:
                    mspersonid = personMap.get(localpersonid,None)
                    if mspersonid is not None:
                        rsp.relationmap[localpersonid] = mspersonid
            logging.info("GetPerson information ok,rsp={}".format(rsp))
            return rsp

def faceServe(port):
    logging.debug("enter")
    global gServer
    gServer = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    faceproto_pb2_grpc.add_FaceIdentyServicer_to_server(FaceGreeter(), gServer)
    gServer.add_insecure_port('[::]:'+port)
    # gServer.add_insecure_port('10.12.23.213:50051')
    gServer.start()
    try:
        while True:
            time.sleep(_ONE_DAY_IN_SECONDS)
    except KeyboardInterrupt:
        gServer.stop(0)


def test():
    logging.info("enter")
    return

if __name__ == '__main__':
    port = sys.argv[1]
    log_init.log_init("/var/log/local_face_server_"+port+".log",'INFO')
    logging.info("start gServer")
    threading.Thread(target=timer).start()
    faceServe(port)
