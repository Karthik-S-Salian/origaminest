import json

def load_classes_data():
    with open("classes.json","r") as fh:
        return json.load(fh)

CLASSES:dict[str,list] =load_classes_data()

CLASSDATA:dict[str,dict] ={}
with open("data.json","r") as fh:
    CLASSDATA = json.loads(fh.read())

def getVideoUrl(cls:str):
    return CLASSDATA.get(cls,{}).get("videoUrl","")


def getMCQ(cls:str):
    return CLASSDATA.get(cls,{}).get("mcqs",[])

def getCategoryClasses(category:str):
    return CLASSES.get(category,[])

def getClasses():
    result =[]
    for category,classes in CLASSES.items():
        d={}
        d["category"] = category
        d["classes"] = classes
        result.append(d)

    return result