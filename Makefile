DRAFT:=anima-brski-cloud
VERSION:=$(shell ./getver ${DRAFT}.md )

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.md ${EXAMPLES}
	kramdown-rfc2629 -3 ${DRAFT}.md >${DRAFT}.v2.xml
	xml2rfc --v2v3 ${DRAFT}.v2.xml && mv ${DRAFT}.v2.v2v3.xml ${DRAFT}.xml
	: git add ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? --text

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? --html -o $@

submit: ${DRAFT}.xml
	curl --http1.1 -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml;type=application/xml" https://datatracker.ietf.org/api/submission | jq

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml

.PRECIOUS: ${DRAFT}.xml
