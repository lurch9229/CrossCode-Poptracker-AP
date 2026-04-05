import jstyleson
import json

f = open('locations/zirvitarTemple.json')
text = f.read()
f.close()

jData = jstyleson.loads(text)
jOut = '[\n'

for jName in jData[0]["children"]:
    Name = jName["name"]
    for jSection in jName["sections"]:
        Section = jSection["name"]
        jOut += '                    {\n                        "ref": "' + Name + '/' + Section + '",\n                        "name": "' + Name + ' - ' + Section + '"\n                    },\n'

jOut += ']'

print(jOut)