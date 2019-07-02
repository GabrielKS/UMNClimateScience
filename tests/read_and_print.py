import resources
import Nio

file = Nio.open_file(resources.LCCMR_ROOT + "CNRM-CM5/HISTORIC/1980-1999/WRF_IBISinput/IBISinput_1980.nc", "r")
print(file.variables["tmax"])

files = resources.get_data_files("CNRM-CM5", "HISTORIC", "1980-1999")
print(files[0].variables["tmax"])

dataset = resources.get_dataset("CNRM-CM5", "HISTORIC", "1980-1999")
print(dataset.variables["tmax"])
