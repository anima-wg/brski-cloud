---
title: "BRSKI Cloud Registrar"
abbrev: BRSKI-CLOUD
docname: draft-ietf-anima-brski-cloud-08
category: std
ipr: trust200902

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
 -
    ins: O. Friel
    name: Owen Friel
    org: Cisco
    email: ofriel@cisco.com
 -
    ins: R. Shekh-Yusef
    name: Rifaat Shekh-Yusef
    org: Ernst & Young
    email: rifaat.s.ietf@gmail.com
 -
    ins: M. Richardson
    name: Michael Richardson
    org: Sandelman Software Works
    email: mcr+ietf@sandelman.ca

normative:
  RFC8366: VOUCHER
  BRSKI: RFC8995
  RFC8366bis: I-D.ietf-anima-rfc8366bis

informative:
  RFC6125:
  I-D.irtf-t2trg-taxonomy-manufacturer-anchors:

venue:
  group: anima
  mail: anima@ietf.org
  github: anima-wg/brski-cloud

--- abstract

Bootstrapping Remote Secure Key Infrastructures defines how to onboard a device securely into an operator maintained infrastructure.  It assumes that there is local network infrastructure for the device to discover and help the device.   This document extends the new device behaviour so that if no local infrastructure is available, such as in a home or remote office, that the device can use a well-defined "call-home" mechanism to find the operator maintained infrastructure.

To this, this document defines how to contact a well-known Cloud Registrar, and two ways in which the new device may be redirected towards the operator maintained infrastructure. The Cloud Registrar enables discovery of the operator maintained infrastructure, and may enable establishment of trust with operator maintained infrastructure that does not support BRSKI mechanisms.

--- middle

# Introduction

Bootstrapping Remote Secure Key Infrastructures {{BRSKI}} BRSKI specifies automated and secure provisioning  of nodes (which are called pledges) with cryptographic keying material (trust  anchors and certificates) to enable authenticated and confidential communication with other similarily enrolled nodes.
This is also called enrolment.

In BRSKI, the pledge performs enrolment by communicating with a BRSKI Registrar belonging to the owner of the pledge.
The pledge does not know who its owner will be when manufactured.
Instead, in BRSKI it is assumed that the network to which the pledge connects belongs to the owner of the pledge and therefore network-supported discovery mechanisms can resolve generic, non-owner specific names to the owners Registrar.

To support enrolment of pledges without such an owner based access network, the mechanisms
of BRSKI Cloud are required which assume that Pledge and Registrar simply connect to the
Internet.
The Internet ("Cloud") connected Registrar will then determine ownership of the Pledge
and redirect the Plege to its owners Registrar.

This work is in support of {{BRSKI, Section 2.7}}, which describes how a pledge

    MAY contact a well-known URI of a Cloud Registrar if a
    local Registrar  cannot be discovered or if the pledge's
    target use cases do not include a local Registrar.


This document further specifies use of a BRSKI Cloud Registrar and clarifies operations that are not sufficiently specified in BRSKI.
Two modes of operation are specified in this document.
The Cloud Registrar may redirect the Pledge to the owner's Registrar, or the Cloud Registrar may issue a voucher to the Pledge that includes the domain of thw owner's Enrollment over Secure Transport {{!RFC7030}} (EST) server.

## Terminology

{::boilerplate bcp14}

This document uses the terms Pledge, Registrar, MASA, and Voucher from {{BRSKI}} and {{RFC8366}}.

Local Domain:
: The domain where the pledge is physically located and bootstrapping from. This may be different to the pledge owner's domain.

Owner Domain:
: The domain that the pledge needs to discover and bootstrap with.

Cloud Registrar:
: The default Registrar that is deployed at a URI that is well known to the pledge.

Owner Registrar:
: The Registrar that is operated by the Owner, or the Owner's delegate.
There may not be an Owner Registrar in all deployment scenarios.

EST:
: Enrollment over Secure Transport {{!RFC7030}}

Manufacturer:
: The term manufacturer is used throughout this document as the entity that created the pledge. This is typically the original equipment manufacturer (OEM), but in more complex situations, it could be a value added retailer (VAR), or possibly even a systems integrator. Refer to {{BRSKI}} for more detailed descriptions of manufacturer, VAR and OEM.

OEM:
: Original Equipment Manufacturer

VAR:
: Value Added Reseller

## Target Use Cases

This document specifies and standardizes procedures for two high level use cases.

- Bootstrap via Cloud Registrar and Owner Registrar: The operator maintained infrastructure supports BRSKI and has a BRSKI Registrar deployed. More details are provided in {{bootstrap-via-cloud-registrar-and-owner-registrar}}.
- Bootstrap via Cloud Registrar and Owner EST Service: The operator maintained infrastructure does not support BRSKI, does not have a BRSKI Registrar deployed, but does have an Enrollment over Secure Transport (EST) {{!RFC7030}} service deployed. More detailed are provided in {{bootstrap-via-cloud-registrar-and-owner-est-service}}.

Common to both uses cases is that they aid with the use of BRSKI in the presence of many small sites, such as teleworkers, with minimum expectations against their network infrastructure.

The pledge is not expected to know whether the operator maintaned infrastructure has a BRSKI Registrar deployed or not.
The pledge determines this based upon the response to its Voucher Request message that it receives from the Cloud Registrar.
The Cloud Registrar is expected to determine whether the operator maintaned infrastructure has a BRSKI Registrar deployed based upon the identity presented by the pledge.

A Cloud Registrar will receive BRSKI communications from all devices configured with its URI.
This could be, for example, all devices of a particular product line from a particular manufacturer.
When this is a significantly large number, a Cloud  Registrar may need to be scaled with the usual web-service scaling mechansisms.

### Bootstrap via Cloud Registrar and Owner Registrar

A pledge is bootstrapping from a location with no local domain Registrar (for example, the small site or teleworker use case with no local infrastructure to provide for automated discovery), and needs to discover its owner Registrar.
The Cloud Registrar is used by the pledge to discover the owner Registrar.
The Cloud Registrar redirects the pledge to the owner Registrar, and the pledge completes bootstrap against the owner Registrar.

A typical example is an employee who is deploying a pledge in a home or small branch office, where the pledge belongs to the employer.
There is no local domain Registrar, the pledge needs to discover and bootstrap with the employer's Registrar which is deployed within the employer's network, and the pledge needs the keying material to trust the Registrar.
For example, an employee is deploying an IP phone in a home office and the phone needs to register to an IP PBX deployed in their employer's office.

Protocol details for this use case are provided in {{redirect2Registrar}}.

### Bootstrap via Cloud Registrar and Owner EST Service

A pledge is bootstrapping where the owner organization does not yet have an owner Registrar deployed, but does have an EST service deployed.
The Cloud Registrar issues a voucher, and the pledge completes trust bootstrap using the Cloud Registrar.
The voucher issued by the cloud includes domain information for the owner's EST service that the pledge should use for certificate enrollment.

For example, an organization has an EST service deployed, but does not have yet a BRSKI capable Registrar service deployed.
The pledge is deployed in the organization's domain, but does not discover a local domain Registrar or owner Registrar.
The pledge uses the Cloud Registrar to bootstrap, and the Cloud Registrar provides a voucher that includes instructions on finding the organization's EST service.

This option can be used to introduce the benefits of BRSKI for an initial period when BRSKI is not available in existing EST-Servers.
Additionally, it can also be used long-term as an security-equivalent solution in which BRSKI and EST-Server are set up in a modular fashion.

The use of an EST-Server instead of a BRSKI Registrar may mean that not all the EST options required by [BRSKI] may be available and hence this option may not support all BRSKI deployment cases.
For example, certificates to enroll into an ACP [RFC8994] needs to include an AcpNodeName (see [RFC8994], Section 6.2.2), which non-BRSKI capable EST-Servers may not support.

Protocol details for this use case are provided in {{voucher2EST}}.

# Architecture

The high level architectures for the two high level use cases are illustrated in {{arch-one}} and {{arch-two}}.

In both use cases, the pledge connects to the Cloud Registrar during bootstrap.

For use case one, as described in {{bootstrap-via-cloud-registrar-and-owner-registrar}}, the Cloud Registrar redirects the pledge to an owner Registrar in order to complete bootstrap with the owner Registrar. When bootstrapping against an owner Registrar, this Registrar will interact with a CA to assist in issuing certificates to the pledge. This is illustrated in {{arch-one}}.

For use case two, as described {{bootstrap-via-cloud-registrar-and-owner-est-service}}, the Cloud Registrar issues a voucher itself without redirecting the pledge to an owner Registrar, the Cloud Registrar will inform the pledge what domain to use for accessing EST services in the voucher response. In this model, the pledge interacts directly with the EST service to enrol. The EST service will interact with a CA to assist in issuing certificated to the pledge. This is illustrated in {{arch-two}}.

It also also possible that the Cloud Registrar may redirect the pledge to another Cloud Registrar operated by a VAR, with that VAR's Cloud Registrar then redirecting the pledge to the Owner Registrar.
This scenario is discussed further in sections {{multiple-http-redirects}} and {{considerationsofor-http-redirect}}.

The mechanisms and protocols by which the Registrar or EST service interacts with the CA are transparent to the pledge and are out-of-scope of this document.

The architectures shows the Cloud Registrar and MASA as being logically separate entities.
The two functions could of course be integrated into a single entity.

There are two different mechanisms for a Cloud Registrar to handle voucher requests.
It can redirect the request to the Owner Registrar for handling, or it can return a voucher
that pins the actual Owner Registrar.
When returning a voucher, additional bootstrapping information is embedded in the voucher.
Both mechanisms are described in detail later in this document.

~~~ aasvg
|<--------------OWNER--------------------------->|   MANUFACTURER

 On-site                Cloud
+--------+                                          +-----------+
| Pledge |----------------------------------------->| Cloud     |
+--------+                                          | Registrar |
    |                                               +-----+-----+
    |                                                     |
    |                 +-----------+                 +-----+-----+
    +---------------->|  Owner    |---------------->|   MASA    |
        VR-sign(N)    | Registrar |sign(VR-sign(N)) +-----------+
                      +-----------+
                            |    +-----------+
                            +--->|    CA     |
                                 +-----------+
~~~
{: #arch-one title="Architecture: Bootstrap via Cloud Registrar and Owner Registrar"}

~~~ aasvg
|<--------------OWNER--------------------------->|   MANUFACTURER

 On-site                Cloud
+--------+                                          +-----------+
| Pledge |----------------------------------------->| Cloud     |
+--------+                                          | Registrar |
    |                                               +-----+-----+
    |                                                     |
    |                                               +-----+-----+
    |                                               |   MASA    |
    |                                               +-----------+
    |                 +-----------+
    +---------------->| EST       |
                      | Server    |
                      +-----------+
                            |    +-----------+
                            +--->|    CA     |
                                 +-----------+
~~~
{: #arch-two title="Architecture: Bootstrap via Cloud Registrar and Owner EST Service"}

As depicted in {{arch-one}} and {{arch-two}}, there are a number of parties involve in the process.
The Manufacturer, or Original Equipment Manufacturer (OEM) builds the device, but also is expected to run the MASA, or arrange for it to exist.

The network operator or enterprise is the intended owner of the new device: the pledge.
This could be the enterprise itself, or in many cases there is some outsourced IT department that might be involved.
They are the operator of the Registrar or EST Server.
They may also operate the CA, or they may contract those services from another entity.

There is a potential additional party involved who may operate the Cloud Registrar: the value added reseller (VAR).
The VAR works with the OEM to ship products with the right configuration to the owner.
For example, SIP telephones or other conferencing systems may be installed by this VAR, often shipped directly from a warehouse to the customer's remote office location.
The VAR and manufacturer are aware of which devices have been shipped to the VAR through sales channel integrations, and so the manufacturer's Cloud Registrar is able to redirect the pledge through a chain of Cloud Registrars, as explained in {{redirect-response}}.

## Network Connectivity

The assumption is that the pledge already has network connectivity prior to connecting to the Cloud Registrar.
The pledge must have an IP address that is able to make DNS queries, and be able to send requests to the Cloud Registrar.
There are many ways to accomplish this, from routeable IPv4 or IPv6 addresses, to use of NAT44, to using HTTP or SOCKS proxies.
There are DHCP options that a network operator can configure to accomplish any of these options.
The pledge operator has already connected the pledge to the network, and the mechanism by which this has happened is out of scope of this document.
For many telephony applications, this is typically going to be a wired connection.

For wireless use cases, some kind of existing Wi-Fi onboarding mechanism such as WPS.
Similarly, what address space the IP address belongs to, whether it is an IPv4 or IPv6 address, or if there are firewalls or proxies deployed between the pledge and the cloud registrar are all out of scope of this document.

## Pledge Certificate Identity Considerations

BRSKI section 5.9.2 specifies that the pledge MUST send an EST {{!RFC7030}} CSR Attributes request to the EST server before it requests a client certificate.
For the use case described in {{bootstrap-via-cloud-registrar-and-owner-registrar}}, the Owner Registar operates as the EST server as described in BRSKI section 2.5.3, and the pledge sends the CSR Attributes request to the Owner Registrar.
For the use case described in {{bootstrap-via-cloud-registrar-and-owner-est-service}}, the EST server operates as described in {{!RFC7030}}, and the pledge sends the CSR Attributes request to the EST server.
Note that the pledge only sends the CSR Attributes request to the entity acting as the EST server as per {{RFC7030}} section 2.6, and MUST NOT send the CSR Attributes request to the Cloud Registrar.
The EST server MAY use this mechanism to instruct the pledge about the identities it should include in the CSR request it sends as part of enrollment.
The EST server may use this mechanism to tell the pledge what Subject or Subject Alternative Name identity information to include in its CSR request.
This can be useful if the Subject must have a specific value in order to complete enrollment with the CA.

EST {{!RFC7030}} is not clear on how the CSR Attributes response should be structured, and in particular is not clear on how a server can instruct a client to include specific attribute values in its CSR.
{{!I-D.ietf-lamps-rfc7030-csrattrs}} clarifies how a server can use CSR Attributes response to specify specific values for attributes that the client should include in its CSR.

For example, the pledge may only be aware of its IDevID Subject which includes a manufacturer serial number, but must include a specific fully qualified domain name in the CSR in order to complete domain ownership proofs required by the CA.

As another example, the Registrar may deem the manufacturer serial number in an IDevID as personally identifiable information, and may want to specify a new random opaque identifier that the pledge should use in its CSR.

# Protocol Operation

This section outlines the high level protocol requirements and operations that take place. Section {{protocol-details}} outlines the exact sequence of message interactions between the pledge, the Cloud Registrar, the Owner Registrar and the Owner EST server.

## Pledge Sends Voucher Request to Cloud Registrar

### Cloud Registrar Discovery

BRSKI defines how a pledge MAY contact a well-known URI of a Cloud Registrar if a local domain Registrar cannot be discovered.
Additionally, certain pledge types might never attempt to discover a local domain Registrar and might automatically bootstrap against a Cloud Registrar.

The details of the URI are manufacturer specific, with BRSKI giving the example "brski-registrar.manufacturer.example.com".

The Pledge SHOULD be provided with the entire URI of the Cloud Registrar, including the protocol and path components, which are typically "https://" and "/.well-known/brski", respectively.

### Pledge - Cloud Registrar TLS Establishment Details

According to {{BRSKI, Section 2.7}}, the pledge MUST use an Implicit Trust Anchor database (see EST {{!RFC7030}}) to authenticate the Cloud Registrar service.
The pledge MUST establish a mutually authenticated TLS connection with the Cloud Registrar.
Unlike the procedures documented in BRSKI section 5.1, the pledge MUST NOT establish a provisional TLS connection with the Cloud Registrar.

Pledges MUST and Cloud/Owner Registrars SHOULD support the use of the "server_name" TLS extension (SNI, RFC6066).
Pledges SHOULD send a valid "server_name" extension whenever they know the domain name of the registrar they connect to, unless it is known that Cloud or Owner Registrars for this pledge implementation will never need to be deployed in a cloud setting requiring the "server_name" extension.

The Pledge MUST be manufactured with pre-loaded trust anchors that are used to verify the identity of the Cloud Registar when establishing the TLS connection.
The TLS connection can be verified using a public Web PKI trust anchor using {{RFC6125}} DNS-ID mechanisms or a pinned certification authority.
This is a local implementation decision.
Refer to {{trust-anchors-for-cloud-registrar}} for trust anchor security considerations.

The Cloud Registrar MUST verify the identity of the pledge by sending a TLS CertificateRequest message to the pledge during TLS session establishment.
The Cloud Registrar MAY include a certificate_authorities field in the message to specify the set of allowed IDevID issuing CAs that pledges may use when establishing connections with the Cloud Registrar.

To protect itself against DoS attacks, the Cloud Registrar SHOULD reject TLS connections when it can determine during TLS authentication that it cannot support the pledge, for example because the plege cannot provide an IDevID signed by a CA recognized/supported by the Cloud Registrar.

### Pledge Sends Voucher Request Message

After the pledge has established a mutually authenticated TLS connection with the Cloud Registrar, the pledge generates a voucher request message as outlined in BRSKI section 5.2, and sends the voucher request message to the Cloud Registrar.

## Cloud Registrar Processes Voucher Request Message

The Cloud Registrar must determine pledge ownership.
Prior to ownership determination, the Registrar checks the request for correctness and if it is unwilling or unable to handle the request, it MUST return a suitable 4xx or 5xx error response to the pledge as defined by {{BRSKI}} and HTTP.
In the case of an unknown pledge a 404 is returned, for a malformed request 400 is returned, or in case of server overload 503 is returned.

If the request is correct and the Registrar is able to handle it, but unable to determine ownership, then it MUST return a 401 Unauthorized response to the pledge.
This signals to the Pledge that there is currently no known owner domain for it, but that retrying later might resolve this situation.
In this scenario, the Registrar SHOULD include a Retry-After header that includes a time to defer.
A pledge with some kind of indicator (such as a screen or LED) SHOULD consider this a bootstrapping failure, and indicate this to the operator.

If the Cloud Registrar successfully determines ownership, then it MUST take one of the following actions:

* error: return a suitable 4xx or 5xx error response (as defined by [BRSKI] and HTTP) to the pledge if the request processing failed for any reason
* redirect to owner registrar: redirect the pledge to an owner registrar via 307 response code
* redirect to owner EST server: issue a voucher (containing an est-domain attribute) and return a 200 response code

### Pledge Ownership Look Up {#pledgeOwnershipLookup}

The Cloud Registrar needs some suitable mechanism for knowing the correct owner of a connecting pledge based on the presented identity certificate.
For example, if the pledge establishes TLS using an IDevID that is signed by a known manufacturing CA, the Registrar could extract the serial number from the IDevID and use this to look up a database of pledge IDevID serial numbers to owners.

The mechanism by which the Cloud Registrar determines pledge ownership is, however, out-of-scope of this document.
The Cloud Registrar is strongly tied to the manufacturers' processes for device identity.

### Bootstrap via Cloud Registrar and Owner Registrar

Once the Cloud Registrar has determined pledge ownership, the Cloud Registrar MAY redirect the pledge to the owner Registrar in order to complete bootstrap.
If the owner wants the Cloud Registar to redirect pledges to their Owner Registrar, the owner must register their Owner Registrar URI with cloud Registar.
The mechanism by which pledge owners register their Owner Registrar URI with the Cloud Registrar is out-of-scope of this document.

In case of redirection, the Cloud Registrar replies to the voucher request with an HTTP 307 Temporary Redirect response code, including the owner's local domain in the HTTP Location header.

### Bootstrap via Cloud Registrar and Owner EST Service

If the Cloud Registrar issues a voucher, it returns the voucher in an HTTP response with a 200 response code.

The Cloud Registrar MAY issue a 202 response code if it is willing to issue a voucher, but will take some time to prepare the voucher.

The voucher MUST include the new "est-domain" field as defined in {{RFC8366bis}}.
This tells the pledge where the domain of the EST service to use for completing certificate enrollment.

The voucher MAY include the new "additional-configuration" field.
This field points the pledge to a URI where pledge specific additional configuration information may be retrieved.
For example, a SIP phone might retrieve a manufacturer specific configuration file that contains information about how to do SIP Registration.
One advantage of this mechanism over current mechanisms like DHCP options 120 defined in {{?RFC3361}} or option 125 defined in {{?RFC3925}} is that the voucher is returned in a confidential (TLS-protected) transport, and so can include device-specific credentials for retrieval of the configuration.

The exact Pledge and Registrar behavior for handling and specifying the "additional-configuration" field is out-of-scope of this document.


## Pledge Handles Cloud Registrar Response

### Bootstrap via Cloud Registrar and Owner Registrar {#redirect-response}

The Cloud Registrar has returned a 307 response to a voucher request.
The Cloud Registrar may be redirecting the pledge to the Owner Registrar, or to a different Cloud Registrar operated by a VAR.

The pledge MUST restart its bootstrapping process by sending a new voucher
request message (with a fresh nonce) using the location provided in the HTTP redirect.
The pledge SHOULD attempt to validate the identity of the Cloud Registrar specified in the 307 response using its Implicit Trust Anchor Database.
If validation of this identity succeeds using the Implicit Trust Anchor Database, then the pledge MAY accept a subsequent 307 response from this Cloud Registrar.
The pledge MAY continue to follow a number of 307 redirects provided that each 307 redirect target Registrar identity is validated using the Implicit Trust Anchor Database.
However, if validation of a 307 redirect target Registrar identity using the Implicit Trust Anchor Database fails, then the pledge MUST NOT accept any further 307 responses from the Registrar, MUST establish a provisional TLS connection with the Registar, and MUST validate the identity of the Registrar using standard BRSKI mechanisms.

The pledge MUST process any error messages as defined in {{BRSKI}}, and in case of error MUST restart the process from its provisioned Cloud Registrar.
The exception is that a 401 Unauthorized code SHOULD cause the Pledge to retry a number of times over a period of a few hours.

The pledge MUST never visit a location that it has already been to, in order to avoid any kind of cycle.
If it happens that a location is repeated, then the pledge MUST fail the bootstrapping attempt and go back to the beginning, which includes listening to other sources of bootstrapping information as specified in {{BRSKI}} section 4.1 and 5.0.
The pledge MUST also have a limit on the total number of redirects it will a follow, as the cycle detection requires that it keep track of the places it has been.
That limit MUST be in the dozens or more redirects such that no reasonable delegation path would be affected.

When the pledge cannot validate the connection, then it MUST establish a provisional TLS connection with the specified local domain Registrar at the location specified.

The pledge then sends a voucher request message via the local domain Registrar.

After the pledge receives the voucher, it verifies the TLS connection to the local domain Registrar and continues with enrollment and bootstrap as per standard BRSKI operation.

The pledge MUST process any error messages as defined in {{BRSKI}}, and in case of error MUST restart the process from its provisioned Cloud Registrar.

The exception is that a 401 Unauthorized code SHOULD cause the Pledge to retry a number of times over a period of a few hours.

### Bootstrap via Cloud Registrar and Owner EST Service

The Cloud Registrar returned a voucher to the pledge.
The pledge MUST perform voucher verification as per BRSKI section 5.6.1.

The pledge SHOULD extract the "est-domain" field from the voucher, and SHOULD continue with EST enrollment as per standard EST operation. Note that the pledge has been instructed to connect to the EST server specified in the "est-domain" field, and therefore SHOULD use EST mechanisms, and not BRSKI mechanisms, when connecting to the EST server.

# Protocol Details


## Bootstrap via Cloud Registrar and Owner Registrar {#redirect2Registrar}

This flow illustrates the Bootstrap via Cloud Registrar and Owner Registrar use case.
A pledge is bootstrapping in a remote location with no local domain Registrar.
The assumption is that the owner Registrar domain is accessible, and the pledge can establish a network connection with the owner Registrar.
This may require that the owner network firewall exposes the owner Registrar on the public internet.

~~~ aasvg
+--------+                                       +----------+
| Pledge |                                       | Cloud    |
|        |                                       |Registrar |
+--------+                                       +----------+
    |                                                 |
    | 1. Mutually-authenticated TLS                   |
    |<----------------------------------------------->|
    |                                                 |
    | 2. Voucher Request                              |
    |------------------------------------------------>|
    |                                                 |
    | 3. 307 Location: owner-ra.example.com           |
    |<------------------------------------------------|
    |
    |                  +-----------+             +---------+
    |                  | Owner     |             |  MASA   |
    |                  | Registrar |             |         |
    |                  +-----------+             +---------+
    | 4. Provisional TLS   |                          |
    |<-------------------->|                          |
    |                      |                          |
    | 5. Voucher Request   |                          |
    |--------------------->| 6. Voucher Request       |
    |                      |------------------------->|
    |                      |                          |
    |                      | 7. Voucher Response      |
    |                      |<-------------------------|
    | 8. Voucher Response  |                          |
    |<---------------------|                          |
    |                      |                          |
    | 9. Verify TLS        |                          |
    |<-------------------->|                          |
    |                      |                          |
    | 10. etc.             |                          |
    |--------------------->|                          |
~~~

The process starts, in step 1, when the Pledge establishes a Mutual TLS channel with the Cloud Registrar using artifacts created during the manufacturing process of the Pledge.

In step 2, the Pledge sends a voucher request to the Cloud Registrar.

The Cloud Registrar determines pledge ownership look up as outlined in {{pledgeOwnershipLookup}}, and determines the owner Registrar domain.
In step 3, the Cloud Registrar redirects the pledge to the owner Registrar domain.

Steps 4 and onwards follow the standard BRSKI flow.
The pledge establishes a provisional TLS connection with the owner Registrar, and sends a voucher request to the owner Registrar.
The Registrar forwards the voucher request to the MASA.
Assuming the MASA issues a voucher, then the pledge verifies the TLS connection with the Registrar using the pinned-domain-cert from the voucher and completes the BRSKI flow.

## Bootstrap via Cloud Registrar and Owner EST Service {#voucher2EST}

This flow illustrates the Bootstrap via Cloud Registrar and Owner EST Service use case.
A pledge is bootstrapping in a location with no local domain Registrar.
The Cloud Registar is instructing the pledge to connect directly to an EST server for enrolment using EST mechanisms.
The assumption is that the EST domain is accessible, and the pledge can establish a network connection with the EST server.

~~~ aasvg
+--------+                                       +----------+
| Pledge |                                       | Cloud    |
|        |                                       |Registrar |
|        |                                       | / MASA   |
+--------+                                       +----------+
    |                                                 |
    | 1. Mutually-authenticated TLS                   |
    |<----------------------------------------------->|
    |                                                 |
    | 2. Voucher Request                              |
    |------------------------------------------------>|
    |                                                 |
    | 3. Voucher Response  {est-domain:fqdn}          |
    |<------------------------------------------------|
    |                                                 |
    |                 +----------+                    |
    |                 | RFC7030  |                    |
    |                 | EST      |                    |
    |                 | Server   |                    |
    |                 +----------+                    |
    |                      |                          |
    | 4. Authenticated TLS |                          |
    |<-------------------->|                          |
    |                                                 |
    |     5a. /voucher_status POST  success           |
    |------------------------------------------------>|
    |     ON FAILURE 5b. /voucher_status POST         |
    |                                                 |
    | 6. EST Enrol         |                          |
    |--------------------->|                          |
    |                      |                          |
    | 7. Certificate       |                          |
    |<---------------------|                          |
    |                      |                          |
    | 8. /enrollstatus     |                          |
    |--------------------->|                          |
~~~

The process starts, in step 1, when the Pledge establishes a Mutual TLS channel with the Cloud Registrar/MASA using artifacts created during the manufacturing process of the Pledge.
In step 2, the Pledge sends a voucher request to the Cloud Registrar/MASA, and in the response in step 3, the Pledge receives an {{RFC8366bis}} format voucher from the Cloud Registrar/MASA that includes its assigned EST domain in the est-domain attribute.

In step 4, the pledge establishes a TLS connection with the EST RA specified in the voucher est-domain attribute.
The connection may involve crossing the Internet requiring a DNS look up on the provided name.
It may also be a local address that includes an IP address literal including both {{?RFC1918}} and IPv6 Unique Local Addresses {{?RFC4193}}.
The artifact provided in the pinned-domain-cert is trested as a trust anchor, and is used to verify the EST server identity.
The EST server identity MUST be verified using the pinned-domain-cert value provided in the voucher as described in {{?RFC7030}} section 3.3.1.

There is a case where the pinned-domain-cert is the identical End-Entity (EE) Certificate as the EST server.
It also explicitly includes the case where the EST server has a self-signed EE Certificate, but it may also be an EE certificate that is part of a larger PKI.
If the certificate is not a self-signed or EE certificate, then the Pledge SHOULD apply {{RFC6125}} DNS-ID verification on the certificate against the domain provided in the est-domain attribute.
If the est-domain was provided by with an IP address literal, then it is unlikely that it can be verified, and in that case, it is expected that either a self-signed certificate or an EE certificate will be pinned by the voucher.

The Pledge also has the details it needs to be able to create the CSR request to send to the RA based on the details provided in the voucher.

In steps 5.a and 5.b, the pledge may optionally notify the Cloud Registrar/MASA of the success or failure of its attempt to establish a secure TLS channel with the EST server.

The Pledge then follows that, in step 6, with an EST Enroll request with the CSR and obtains the requested certificate.
The Pledge must verify that the issued certificate in step 7 has the expected identifier obtained from the Cloud Registrar/MASA in step 3.

# YANG extension for Voucher based redirect {#redirected}

{{RFC8366bis}} contains the two needed voucher extensions: est-domain and additional-configuration which are needed when a client is redirected to a local EST server.

# IANA Considerations

This document makes no IANA requests.

# Implementation Considerations

## Captive Portals

A Pledge may be deployed in a network where a captive portal or an intelligent home gateway that provides access control on all connections is also deployed.
Captive portals that do not follow the requirements of {{?RFC8952}} section 1 may forcibly redirect HTTPS connections.
While this is a deprecated practice as it breaks TLS in a way that most users can not deal with, it is still common in many networks.

When the PLedge attempts to connect to the Cloud Registrar, an incorrect connection will be detected because the Pledge will be unable to verify the TLS connection to its Cloud Registrar via DNS-ID check {{?RFC9525, Section 6.3}}.
That is, the certificate returned from the captive portal will not match.

At this point a network operator who controls the captive portal, noticing the connection to what seems a legitimate destination (the Cloud Registrar), may then permit that connection.
This enables the first connection to go through.

The connection is then redirected to the Registrar via 307, or to an EST server via est-domain in a voucher.
If it is a 307 redirect, then a provisional TLS connection will be initiated, and it will succeed.
The provisional TLS connection does not do {{RFC9525, Section 6.3}} DNS-ID verification at the beginning of the connection, so a forced redirection to a captive portal system will not be detected.
The subsequent BRSKI POST of a voucher will most likely be met by a 404 or 500 HTTP code.

It is RECOMMENDED therefore that the pledge look for {{?RFC8910}} attributes in DHCP, and if present, use the {{?RFC8908}} API to learn if it is captive.

The scenarios outlined here when a Pledge is deployed behind a captive portal may result in failure scenarios, but do not constitute a secty risk, as the Pledge is correctly verifyng all TLS connections as per {{BRSKI}}.

## Multiple HTTP Redirects

If the Redirect to Registrar method is used, as described in {{redirect2Registrar}}, there may be a series of 307 redirects.
An example of why this might occur is that the manufacturer only knows that it resold the device to a particular value added reseller (VAR), and there may be a chain of such VARs.
It is important the pledge avoid being drawn into a loop of redirects.
This could happen if a VAR does not think they are authoritative for a particular device.
A "helpful" programmer might instead decide to redirect back to the manufacturer in an attempt to restart at the top:  perhaps there is another process that updates the manufacturer's database and this process is underway.
Instead, the VAR MUST return a 404 error if it cannot process the device.
This will force the device to stop, timeout, and then try all mechanisms again.

# Security Considerations

The Cloud Registrar described in this document inherits all the strong security properties that are described in {{BRSKI}}, and none of the security mechanisms that are defined in {{BRSKI}} are bypassed or weakened by this document.
The Cloud Registrar also inherits all the potential issues that are described in {{BRSKI}}.
This includes dependency upon continued operation of the manufacturer provided MASA, as well as potential complications where a manufacturer might interfere with
resale of a device.

In addition to the dependency upon the MASA, the successful enrollment of a device using a Cloud Registrar depends upon the correct and continued operation of this new service.
This internet accessible service may be operated by the manufacturer and/or by one or more value-added-resellers.
All the considerations for operation of the MASA also apply to operation of the Cloud Registrar.

## Security Updates for the Pledge

Unlike many other uses of BRSKI, in the Cloud Registrar case it is assumed that the Pledge has connected to a network on which there is addressing and connectivity, but there is no other local configuration available.

There is another advantage to being online: the pledge may be able to contact the manufacturer before bootstrapping in order to apply the latest firmware updates.
This may also include updates to the Implicit list of Trust Anchors.
In this way, a Pledge that may have been in a dusty box in a warehouse for a long time can be updated to the latest (exploit-free) firmware before attempting bootstrapping.

## Trust Anchors for Cloud Registrar

The Implicit Trust Anchor database is used to authenticate the Cloud Registrar.
This list is built-in by the manufacturer along with a DNS name to which to connect.
(The manufacturer could even build in IP addresses as a last resort)

The Cloud Registrar may have a certificate that can be verified using a public (WebPKI) anchor.
If one or more public WebPKI anchors are used, it is recommended to limit the number of WebPKI anchors to only those necessary for establishing trust with the Cloud Registrar.
As another option, the Cloud Registrar may have a certificate that can be verified using a Private/Cloud PKI anchor as described in {{?I-D.irtf-t2trg-taxonomy-manufacturer-anchors}} section 3.
The trust anchor, or trust anchors, to use is an implementation decision and out of scope of this document.

The pledge may have any kind of Trust Anchor built in: from full multi-level WebPKI to the single self-signed certificate used by the Cloud Registrar.
There are many tradeoffs to having more or less of the PKI present in the Pledge, which is addressed in part in {{?I-D.irtf-t2trg-taxonomy-manufacturer-anchors}} in sections 3 and 5.

## Considerations for HTTP Redirect

When the default Cloud Registrar redirects a Pledge using HTTP 307 to an Owner Registrar, or another Cloud Registrar operated by a VAR, the Pledge MUST establish a provisional TLS connection with the Registrar as specified in {{BRSKI}}.
The Pledge is unable to determine whether it has been redirected to another Cloud Registrar that is operated by a VAR, or it it has been redirected to an Owner Registrar, and does not differentiate between the two scenarios.

## Considerations for Voucher est-domain

A Cloud Registrar supporting the same set of pledges as a MASA may be integrated with the MASA to avoid the need for a network based API between them, and without changing their external behavior as specified here.

When a Cloud Registrar handles the scenario described in {bootstrapping-with-no-owner-registrar} by the returning "est-domain" attribute in the voucher, the Cloud Registrar actually does all the voucher processing as specified in {{BRSKI}}.
This is an example deployment scenario where the Cloud Registrar may be operated by the same entity as the MASA, and it may even be integrated with the MASA.

When a voucher is issued by the Cloud Registrar and that voucher contains an "est-domain attribute, the Pledge MUST verify the TLS connection with this EST server using the "pinned-domain-cert" attribute in the voucher.

# Acknowledgements
{: numbered="no"}

The authors would like to thank for following for their detailed reviews: (ordered
by last name): Esko Dijk, Sheng Jiang.


