from tensorflow import lite as tflite
import numpy as np
from io import BytesIO
from PIL import Image
import constants
from os import path
from data import CLASSES,getCategoryClasses


class Model:
    def __init__(self,model_path:str,category:str) -> None:
        self.model_path = model_path
        self.category = category
        self.classes = getCategoryClasses(self.category)
        self.intialize_model()

    def intialize_model(self):
        self.interpreter: tflite.Interpreter = tflite.Interpreter(model_path=self.model_path)
        self.interpreter.allocate_tensors()
        input_details = self.interpreter.get_input_details()[0]
        self.input_width:int = input_details["shape"][1]
        self.input_height:int = input_details["shape"][2]
        self.tensor_index = input_details["index"]
        self.output_tensor_index = self.interpreter.get_output_details()[0]['index']

    def generate_inference(self,data:bytes)->tuple[str,float]:
        image = Image.open(BytesIO(data))
        image = image.resize((self.input_width, self.input_height))
        image = np.array(image)
        image = image.astype(np.float32) / 255.0
        self.interpreter.set_tensor(self.tensor_index, np.expand_dims(image, axis=0))
        self.interpreter.invoke()
        output_data = self.interpreter.get_tensor(self.output_tensor_index)
        return self.classes[np.argmax(output_data)],round(np.max(output_data)*100,2)


def initilaizeModels():
    models ={}
    for category in CLASSES.keys():
        models[category] = Model(path.join(constants.MODELS_DIR,f"{category}.tflite"),category)
    return models

MODELS:dict[str,Model] = initilaizeModels()

def generate_inference(category:str,file:bytes)->tuple[str,float]:
    model = MODELS[category]
    return model.generate_inference(file)
