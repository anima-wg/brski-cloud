DRAFT:=anima-brski-cloud
VERSION:=$(shell ./getver ${DRAFT}.md )
YANGDATE=2020-09-23
YANGFILE=yang/ietf-voucher-redirected@${YANGDATE}.yang
PYANG=pyang
EXAMPLES=ietf-voucher-redirected-tree.txt
EXAMPLES+=${YANGFILE}

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.md ${EXAMPLES}
	kramdown-rfc2629 -3 ${DRAFT}.md | ./insert-figures >${DRAFT}.v2.xml
	xml2rfc --v2v3 ${DRAFT}.v2.xml && mv ${DRAFT}.v2.v2v3.xml ${DRAFT}.xml
	: git add ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? --text

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? --html -o $@

yang:
	mkdir -p yang

${YANGFILE}: ietf-voucher-redirected.yang yang
	sed -e"s/YYYY-MM-DD/${YANGDATE}/" ietf-voucher-redirected.yang > ${YANGFILE}

ietf-voucher-redirected-tree.txt: ${YANGFILE} yang
	pyang --path=../voucher -f tree --tree-print-groupings ${YANGFILE} > ietf-voucher-redirected-tree.txt

submit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml;type=application/xml" https://datatracker.ietf.org/api/submit

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml

.PRECIOUS: ${DRAFT}.xml
