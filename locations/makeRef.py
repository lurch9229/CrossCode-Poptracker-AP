import jstyleson
import json

f = open('locations/azureArchipelago.json')
text = f.read()
f.close()

jData = jstyleson.loads(text)
jOut = '[\n'

for jName in jData[0]["children"]:
    if "name" in jName:
        Name = jName["name"]
        for jSection in jName["sections"]:
            Section = jSection["name"]
            jOut += '                    {\n                        "ref": "' + Name + '/' + Section + '",\n                        "name": "' + Name + '\\n' + Section + '"\n                    },\n'

jOut += ']'

print(jOut)