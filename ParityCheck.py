##Calling as :  ParityCheck.py {\"compare\": {\"source1\":\"target1\", \"source2\":\"target2\"} }

import json, sys
import random

output = {}
returnObj = {}

inputString = ' '.join(sys.argv[1:])
# print (inputString);
# print (type(inputString))

inputDict =json.loads(inputString)
#print (type(inputDict))

comparePairs = inputDict["compare"]
for key, value in comparePairs.items():
	#print('Key : ' , key , ' and Values is :' , value)
	if key not in output:
		status = ["Y", "N"]    
		random.shuffle(status) 
		output[key] = status[0]

# for key, value in output.items():
	# print('Key : ' , key , ' and Values is :' , value)

returnObj["result"] = output
JsonReturnObj = json.dumps(returnObj)	

print(JsonReturnObj)
#return(JsonReturnObj)
sys.exit()

for key, value in a.items():
	print('Key : ' , key , ' and Values is :' , value)
	if key not in output:
		output[key] = "Y"
js_Obj = json.dumps(output)
print (type(js_Obj))

# input = ''.join(str(e) for e in input)
# print (input);
# print (type(input))

# a =json.loads(' + input + ')
# print (type(a))
# for key, value in a.items():
	# print('Key : ' , key , ' and Values is :' , value)	
	# if key not in output:
		# output[key] = "Y"
# print (dict(output))
sys.exit()

#print (input)

#j = json.loads('{"one" : "1", "two" : "2", "three" : "3"}')

# input = json.loads(sys.argv[1])
# data_str=json.dumps(input)

# print (data_str)

output = {}
json_string = '{"name":"Rupert", "age": 25, "desig":"developer"}'
print (type (json_string))

def func(strng):
	a =json.loads(strng)
	print (type(a))
	array1 = list(a.keys())
	for key in array1:
		print("key and value pair :", key , a[key])
	
	for key, value in a.items():
		print('Key : ' , key , ' and Values is :' , value)
		if key not in output:
			output[key] = value
	
	print('now')	
	print (dict(a))
	print (dict(output))
	print('dd')
	### below is the output style.. where output is a dictionary
	js_Obj = json.dumps(output)
	print (type(js_Obj))
	
	a =json.loads(js_Obj)
	print (type(a))
	for key, value in a.items():
		print('Key : ' , key , ' and Values is :' , value)
	
func(json_string)