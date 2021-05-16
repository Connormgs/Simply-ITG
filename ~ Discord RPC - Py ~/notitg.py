"""
[]================▄███▄================[]
||               ██▀▀██▌▒              ||
||              ▐█▌ ▒▐██ ▒             ||
||              ██ ▒ ▐██ ▒             ||
||              ██   ██▌ ▒             ||
||              ██  ██▌ ▒              ||
||              ▀ ▄██▌ ▒               ||
||              ▄███▌ ▒                ||
||             ████  ▒▒▒▒▒             ||
||            ████ ■ ▄▄▄  ▒            ||
||           ████  ▄█████▄ ▒           ||
||          ████  ████████▄ ▒          ||
||         ▄███  ▐██▀   ███ ▒          ||
||         ████ ▒ █▌ █▌  ██▌ ▒         ||
||         ████   ▐█ ▐█  ██ ▒          ||
||          ████   ▐▌ █▌▐█▌▒           ||
||.          ▀████▄  ▄▐█ ▌ ▒           ||
||          ▒   ▀▀████ █▌ ▒            ||
||.          ▒▒▒       ▐█ ▒         .  ||
||.    .        ▒▒▒▒▒▒▒ █▌ ▒     .    .||
||  .     .   .        .▐█ ▒    .      ||
||. .. .        .   .    █▌ ▒ .   . . .||
||....  .  .   ▄██▄.   . ▐█ ▒  . .  ...||
||:.....  .   █████▌▒ .. █▌ ▒.  . ....:||
||:::...... . █████▌▒ ..▐█ ▒. ......:::||
||::;::.:.. .. ███▌ ...▄█▌ ▒....:.:::::||
[]==============▀███████▀==============[]


"fuck you im jasmine, moo"
- Jaezmien Naejara (2020)

"""

# somehow, python 3 is a blessing

import ctypes as ct
import ctypes.wintypes as wt
import psutil

# https://stackoverflow.com/a/33858255

PROCESS_VM_READ = 0x10
PROCESS_VM_WRITE = 0x20
PROCESS_VM_OPERATION = 0x8
k32 = ct.WinDLL('kernel32')
OpenProcess = k32.OpenProcess
OpenProcess.argtypes = [wt.DWORD,wt.BOOL,wt.DWORD]
OpenProcess.restype = wt.HANDLE
ReadProcessMemory = k32.ReadProcessMemory
ReadProcessMemory.argtypes = [wt.HANDLE,wt.LPCVOID,wt.LPVOID,ct.c_size_t,ct.POINTER(ct.c_size_t)]
ReadProcessMemory.restype = wt.BOOL
WriteProcessMemory = k32.WriteProcessMemory
WriteProcessMemory.restype = wt.BOOL
WriteProcessMemory.argtypes = [wt.HANDLE,wt.LPVOID,wt.LPCVOID,ct.c_size_t,ct.POINTER(ct.c_size_t)]

_NotITG_Versions = {
	"V1": {
		"BuildAddress": 0x006AED20,
		"Address": 0x00896950,
		"BuildDate": 20161224,
	},
	"V2": {
		"BuildAddress": 0x006B7D40,
		"Address": 0x008A0880,
		"BuildDate": 20170405,
	},
	"V3": {
		"BuildAddress": 0x006DFD60,
		"Address": 0x008CC9D8,
		"BuildDate": 20180617,
	},
	"V3.1": {
		"BuildAddress": 0x006E7D60,
		"Address": 0x008BE0F8,
		"BuildDate": 20180827,
	},
	"V4": {
		"BuildAddress": 0x006E0E60,
		"Address": 0x008BA388,
		"BuildDate": 20200112,
	},
	"V4.0.1": {
		"BuildAddress": 0x006C5E40,
		"Address": 0x00897D10,
		"BuildDate": 20200126,
	},
	"V4.2": {
		"BuildAddress": 0x006FAD40,
		"Address": 0x008BFF38,
		"BuildDate": 20210420
	}
}

_NotITG_Files = {
	# These are the default filenames.

	"V1"    : "NotITG.exe",         # V1
	"V2"    : "NotITG-170405.exe",  # V2
	"V3"    : "NotITG-V3.exe",      # V3
	"V3.1"  : "NotITG-V3.1.exe",    # V3.1
	"V4"    : "NotITG-V4.exe",      # V4
	"V4.0.1": "NotITG-V4.0.1.exe",  # V4.0.1
	"V4.2"  : "NotITG-V4.2.0.exe",  # V4.2
}

class NotITG:
	def __init__(self, version, k32process, processID):
		self.version = version
		self.k32process = k32process
		self.processID = processID
		self.details = _NotITG_Versions[ self.version ]
	
	def GetExternal(self,index = 0) -> int:
		max_index = 255
		if self.version == "V1" or self.version == "V2":
			max_index = 9
		elif self.version == "V3" or self.version == "V3.1" or self.version == "V4" or self.version == "V4.0.1":
			max_index = 63
		if index < 0 or index > max_index:
			raise NotITGError("Index is outside range! [0-{}]".format(max_index))
		# This was a pain to find out.
		data = ct.c_int()
		bytesRead = ct.c_size_t()
		ReadProcessMemory(self.k32process, self.details['Address'] + (index*4), ct.byref(data), ct.sizeof(data), ct.byref(bytesRead))
		return data.value
	def SetExternal(self, index, flag):
		max_index = 255
		if self.version == "V1" or self.version == "V2":
			max_index = 9
		elif self.version == "V3" or self.version == "V3.1" or self.version == "V4" or self.version == "V4.0.1":
			max_index = 63
		if index < 0 or index > max_index:
			raise NotITGError("Index is outside range! [0-{}]".format(max_index))
		data = ct.c_int( flag )
		bytesWrite = ct.c_size_t()
		result = WriteProcessMemory(self.k32process, self.details['Address'] + (index*4), bytes(data), ct.sizeof(data), ct.byref(bytesWrite)) # bytes( data ) took some time to figure out.

class Error(Exception):
	pass
class NotITGError(Error):
	def __init__(self, message):
		self.message = message

def Scan(known_filename = True):
	for proc in psutil.process_iter():
		try:
			ct_process = k32.OpenProcess(PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION, False, proc.pid)
			if known_filename:
				for v, file_name in _NotITG_Files.items():    
					if proc.name().lower() == file_name.lower():
						return NotITG(v, ct_process, proc.pid)
			else:
				# Held by duct-tape and toothpicks.
				for v,addresses in _NotITG_Versions.items():
					str_len = 8
					data = ct.create_string_buffer(str_len)
					ReadProcessMemory(ct_process, addresses['BuildAddress'], ct.byref(data), str_len, ct.byref(ct.c_size_t()))
					try:
						if data.value.decode() == str(addresses['BuildDate']):
							return NotITG(v, ct_process, proc.pid)
					except:
						pass
		except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
			pass

	raise NotITGError("NotITG not found.")

def Heartbeat(nitg: NotITG) -> bool:
	for proc in psutil.process_iter():
		if proc.pid == nitg.processID:
			return True
	return False
