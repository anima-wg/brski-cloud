---
title: "BRSKI Cloud Registrar"
abbrev: BRSKI-CLOUD
docname: draft-ietf-anima-brski-cloud-12
category: std
ipr: trust200902
updates: 8995

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
    org: Ciena
    email: rifaat.s.ietf@gmail.com
 -
    ins: M. Richardson
    name: Michael Richardson
    org: Sandelman Software Works
    email: mcr+ietf@sandelman.ca

normative:
  RFC6066: SNI
  RFC8366: VOUCHER
  RFC8994: ACP
  BRSKI: RFC8995
  RFC8366bis: I-D.ietf-anima-rfc8366bis

informative:
  RFC9525:
  I-D.irtf-t2trg-taxonomy-manufacturer-anchors:
  WPS:
    title: "Wi-Fi Protected Setup (WPS)"
    date: January 2025
    target: https://www.wi-fi.org/discover-wi-fi/wi-fi-protected-setup
    author:
      org: "WiFi Alliance"

venue:
  group: anima
  mail: anima@ietf.org
  github: anima-wg/brski-cloud

--- abstract

Bootstrapping Remote Secure Key Infrastructures defines how to onboard a device securely into an operator-maintained infrastructure.  It assumes that there is local network infrastructure for the device to discover and help the device.   This document extends the new device behavior so that if no local infrastructure is available, such as in a home or remote office, the device can use a well-defined "call-home" mechanism to find the operator-maintained infrastructure.

This document defines how to contact a well-known Cloud Registrar, and two ways in which the new device may be redirected towards the operator-maintained infrastructure. The Cloud Registrar enables discovery of the operator-maintained infrastructure, and may enable establishment of trust with operator-maintained infrastructure that does not support BRSKI mechanisms.

--- middle

# Introduction

Bootstrapping Remote Secure Key Infrastructures {{BRSKI}} BRSKI specifies automated and secure provisioning  of nodes (which are called Pledges) with cryptographic keying material (trust  anchors and certificates) to enable authenticated and confidential communication with other similarly enrolled nodes.
This is also called enrollment.

In BRSKI, the Pledge performs enrollment by communicating with a BRSKI Registrar belonging to the owner of the Pledge.
The Pledge does not know who its owner will be when manufactured.
Instead, in BRSKI it is assumed that the network to which the Pledge connects belongs to the owner of the Pledge and therefore network-supported discovery mechanisms can resolve generic, non-owner specific names to the owner's Registrar.

To support enrollment of Pledges without such an owner based access network, the mechanisms
of BRSKI Cloud are required which assume that Pledge and Registrar simply connect to the
Internet.

This work is in support of {{BRSKI, Section 2.7}}, which describes how a Pledge MAY contact a well-known URI of a Cloud Registrar if a local Registrar cannot be discovered or if the Pledge's target use cases do not include a local Registrar.

This kind of non-network onboarding is sometimes called "Application Onboarding", as the purpose is typically to deploy a credential that will be used by the device in its intended use.
For instance, a SIP phone might have a client certificate to be used with a SIP proxy.

This document further specifies use of a BRSKI Cloud Registrar and clarifies operations that are left out of scope in {{BRSKI}}.
Two modes of operation are specified in this document.
The Cloud Registrar may redirect the Pledge to the owner's Registrar, or the Cloud Registrar may issue a voucher to the Pledge that includes the domain of the owner's Enrollment over Secure Transport {{!RFC7030}} (EST) server.


## Terminology

{::boilerplate bcp14}

This document uses the terms Pledge, Registrar, MASA, and Voucher from {{BRSKI}} and {{RFC8366}}.

Cloud Registrar:
: The default Registrar that is deployed at a URI that is well known to the Pledge.

EST:
: Enrollment over Secure Transport {{!RFC7030}}

Local Domain:
: The domain where the Pledge is physically located and bootstrapping from. This may be different from the Pledge owner's domain.

Manufacturer:
: The term manufacturer is used throughout this document as the entity that created the Pledge. This is typically the original equipment manufacturer (OEM), but in more complex situations, it could be a value added retailer (VAR), or possibly even a systems integrator. Refer to {{BRSKI}} for more detailed descriptions of manufacturer, VAR and OEM.

Owner Domain:
: The domain that the Pledge needs to discover and bootstrap with.

Owner Registrar:
: The Registrar that is operated by the Owner, or the Owner's delegate.
There may not be an Owner Registrar in all deployment scenarios.

OEM:
: Original Equipment Manufacturer

Provisional TLS:
: A mechanism defined in {{BRSKI, Section 5.1}} whereby a Pledge establishes a provisional TLS connection with a Registrar before the Pledge is provisioned with a trust anchor that can be used for verifying the Registrar identity.

VAR:
: Value Added Reseller

Cloud VAR Registrar:
: The non-default Registrar that is operated by a value added reseller (VAR).


## Target Use Cases

This document specifies procedures for two high-level use cases.

- Bootstrap via Cloud Registrar and Owner Registrar: The operator-maintained infrastructure supports BRSKI and has a BRSKI Registrar deployed. More details are provided in {{bootstrap-via-cloud-registrar-and-owner-registrar}}.
- Bootstrap via Cloud Registrar and Owner EST Service: The operator-maintained infrastructure does not support BRSKI, does not have a BRSKI Registrar deployed, but does have an Enrollment over Secure Transport (EST) {{!RFC7030}} service deployed. More detailed are provided in {{bootstrap-via-cloud-registrar-and-owner-est-service}}.

Common to both uses cases is that they aid with the use of BRSKI in the presence of many small sites, such as teleworkers, with minimum expectations against their network infrastructure.

This use case also supports situations where a manufacturer sells a number of devices (in bulk) to a Value Added Reseller (VAR).
The manufacturer knows which devices have been sold to which VAR, but not who the ultimate owner will be.
The VAR then sells devices to other entities, such as enterprises, and records this.
A typical example is a VoIP phone manufacturer provides telephones to a local system integration company (a VAR).
The VAR records this sale to its Cloud VAR Registrar system.

In this use case, this VAR has sold and services a VoIP system to an enterprise (e.g., a SIP PBX).
When a new employee needs a phone at their home office, the VAR ships that unit across town to the employee.  When the employee plugs in the device and turns it on, the device will be provisioned with a LDevID and configuration that connections the phone with the Enterprises' VoIP PBX.
The home employee's network has no special provisions.

This use case also supports a chain of VARs through chained HTTP redirects.
This also supports a situation where in effect, a large enterprise might also stock devices in a central location.


The Pledge is not expected to know whether the operator-maintained infrastructure has a BRSKI Registrar deployed or not.
The Pledge determines this based upon the response to its Voucher Request message that it receives from the Cloud Registrar.
The Cloud Registrar is expected to determine whether the operator-maintained infrastructure has a BRSKI Registrar deployed based upon the identity presented by the Pledge.

A Cloud Registrar will receive BRSKI communications from all devices configured with its URI.
This could be, for example, all devices of a particular product line from a particular manufacturer.
When this is a significantly large number, a Cloud  Registrar may need to be scaled with the usual web-service scaling mechanisms.

### Bootstrap via Cloud Registrar and Owner Registrar

A Pledge is bootstrapping from a location with no local domain Registrar (for example, the small site or teleworker use case with no local infrastructure to provide for automated discovery), and needs to discover its Owner Registrar.
The Cloud Registrar is used by the Pledge to discover the Owner Registrar.
The Cloud Registrar redirects the Pledge to the Owner Registrar, and the Pledge completes bootstrap against the Owner Registrar.

This mechanism is useful to help an employee who is deploying a Pledge in a home or small branch office, where the Pledge belongs to the employer.
As there is no local domain Registrar in the employee's local network, the Pledge needs to discover and bootstrap with the employer's Registrar which is deployed within the employer's network, and the Pledge needs the keying material to trust the Registrar.
As a very specific example, an employee is deploying an IP phone in a home office and the phone needs to register to an IP PBX deployed in their employer's office.

Protocol details for this use case are provided in {{redirect2Registrar}}.

### Bootstrap via Cloud Registrar and Owner EST Service

A Pledge is bootstrapping where the owner organization does not yet have an Owner Registrar deployed, but does have an EST service deployed.
The Cloud Registrar issues a voucher, and the Pledge completes trust bootstrap using the Cloud Registrar.
The voucher issued by the cloud includes domain information for the owner's EST service that the Pledge should use for certificate enrollment.

For example, an organization has an EST service deployed, but does not have yet a BRSKI-capable Registrar service deployed.
The Pledge is deployed in the organization's domain, but does not discover a local domain Registrar or Owner Registrar.
The Pledge uses the Cloud Registrar to bootstrap, and the Cloud Registrar provides a voucher that includes instructions on finding the organization's EST service.

This option can be used to introduce the benefits of BRSKI for an initial period when BRSKI is not available in existing EST-Servers.
Additionally, it can also be used long-term as a security-equivalent solution in which BRSKI and EST-Server are set up in a modular fashion.

The use of an EST-Server instead of a BRSKI Registrar may mean that not all the EST options required by [BRSKI] may be available and hence this option may not support all BRSKI deployment cases.
For example, certificates to enroll into an ACP [RFC8994] needs to include an AcpNodeName (see {{RFC8994, Section 6.2.2}}, which non-BRSKI-capable EST-Servers may not support.

Protocol details for this use case are provided in {{voucher2EST}}.

# Architecture

The high-level architectures for the two high-level use cases are illustrated in {{arch-one}} and {{arch-two}}.

In both use cases, the Pledge connects to the Cloud Registrar during bootstrap.

For use case one, as described in {{bootstrap-via-cloud-registrar-and-owner-registrar}}, the Cloud Registrar redirects the Pledge to an Owner Registrar in order to complete bootstrap with the Owner Registrar. When bootstrapping against an Owner Registrar, the Owner Registrar will interact with a CA to assist in issuing certificates to the Pledge. This is illustrated in {{arch-one}}.

For use case two, as described {{bootstrap-via-cloud-registrar-and-owner-est-service}}, the Cloud Registrar issues a voucher itself without redirecting the Pledge to an Owner Registrar. The Cloud Registrar will inform the Pledge what domain to use for accessing EST services in the voucher response. In this model, the Pledge interacts directly with the EST service to enroll. The EST service will interact with a CA to assist in issuing a certificate to the Pledge. This is illustrated in {{arch-two}}.

It is also possible that the Cloud Registrar may redirect the Pledge to another Cloud Registrar operated by a VAR, with that VAR's Cloud Registrar then redirecting the Pledge to the Owner Registrar.
This scenario is discussed further in Sections {{multiplehttpredirects}} and {{<considerationsfor-http-redirect}}.

The mechanisms and protocols by which the Registrar or EST service interacts with the CA are transparent to the Pledge and are outside the scope of this document.

The architectures show the Cloud Registrar and MASA as being logically separate entities.
The two functions could of course be integrated into a single entity.

There are two different mechanisms for a Cloud Registrar to handle voucher requests.
It can redirect the request to the Owner Registrar for handling, or it can return a voucher
that includes an est-domain attribute that points to the Owner EST Service.
When returning a voucher, additional bootstrapping information is embedded in the voucher.
Both mechanisms are described in detail later in this document.

~~~ aasvg
|<--------------OWNER--------------------------->|   MANUFACTURER

 On-site                Cloud
+--------+                                          +-----------+
| Pledge |----------------------------------------->| Cloud     |
+--------+                                          | Registrar |
    |                                               +-+---------+
    |                                                 | BRSKI-MASA
    |                 +-----------+                 +-+---------+
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
    |                                               +--+--------+
    |                                                  | BRSKI-MASA
    |                                               +--+--------+
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
The interation between the Cloud Registrar and the MASA is described by {{BRSKI, Section 5.4}}.

The network operator or enterprise is the intended owner of the new device: the Pledge.
This could be the enterprise itself, or in many cases there is some outsourced IT department that might be involved.
They are the operator of the Registrar or EST Server.
They may also operate the CA, or they may contract those services from another entity.

There is a potential additional party involved who may operate the Cloud Registrar: the value added reseller (VAR).
The VAR works with the OEM to ship products with the right configuration to the owner.
For example, SIP telephones or other conferencing systems may be installed by this VAR, often shipped directly from a warehouse to the customer's remote office location.
The VAR and manufacturer are aware of which devices have been shipped to the VAR through sales channel integrations, and so the manufacturer's Cloud Registrar is able to redirect the Pledge through a chain of Cloud Registrars, as explained in {{redirect-response}}.

## Network Connectivity

The assumption is that the Pledge already has network connectivity prior to connecting to the Cloud Registrar.
The Pledge must have an IP address so that it is able to make DNS queries, and be able to send requests to the Cloud Registrar.
There are many ways to accomplish this, from routable IPv4 or IPv6 addresses, to use of NAT44, to using HTTP or SOCKS proxies.
There are DHCP options that a network operator can configure to accomplish any of these options.
The Pledge operator has already connected the Pledge to the network, and the mechanism by which this has happened is out of scope of this document.
For many telephony applications, this is typically going to be a wired
connection. For wireless use cases, existing Wi-Fi onboarding mechanisms such as {{WPS}} can be used.

Similarly, what address space the IP address belongs to, whether it is an IPv4 or IPv6 address, or if there are firewalls or proxies deployed between the Pledge and the cloud registrar are all out of scope of this document.

## Pledge Certificate Identity Considerations

{{Section 5.9.2 of BRSKI}} specifies that the Pledge MUST send an EST {{!RFC7030}} CSR Attributes request to the EST server before it requests a client certificate.
For the use case described in {{bootstrap-via-cloud-registrar-and-owner-registrar}}, the Owner Registrar operates as the EST server as described in {{BRSKI, Section 2.5.3}}, and the Pledge sends the CSR Attributes request to the Owner Registrar.
For the use case described in {{bootstrap-via-cloud-registrar-and-owner-est-service}}, the EST server operates as described in {{!RFC7030}}, and the Pledge sends the CSR Attributes request to the EST server.
Note that the Pledge only sends the CSR Attributes request to the entity acting
as the EST server as per {{Section 2.6 of !RFC7030}}, and MUST NOT send the CSR
Attributes request to the Cloud Registrar.
The EST server MAY use this mechanism to instruct the Pledge about the identities it should include in the CSR request it sends as part of enrollment.
The EST server may use this mechanism to tell the Pledge what Subject or Subject Alternative Name identity information to include in its CSR request.
This can be useful if the Subject must have a specific value in order to complete enrollment with the CA.

EST {{!RFC7030}} is not clear on how the CSR Attributes response should be structured, and in particular is not clear on how a server can instruct a client to include specific attribute values in its CSR.
{{!I-D.ietf-lamps-rfc7030-csrattrs}} clarifies how a server can use CSR Attributes response to specify specific values for attributes that the client should include in its CSR.

For example, the Pledge may only be aware of its IDevID Subject which includes a manufacturer serial number, but must include a specific fully qualified domain name in the CSR in order to complete domain ownership proofs required by the CA.

As another example, the Registrar may deem the manufacturer serial number in an IDevID as personally identifiable information, and may want to specify a new random opaque identifier that the Pledge should use in its CSR.

## YANG extension for Voucher based redirect {#redirected}

{{RFC8366bis}} contains the two needed voucher extensions: est-domain and additional-configuration which are needed when a client is redirected to a local EST server.

# Protocol Operation

This section outlines the high-level protocol requirements and operations that take place. {{protocol-details}} outlines the exact sequence of message interactions between the Pledge, the Cloud Registrar, the Owner Registrar and the Owner EST server.

## Pledge Sends Voucher Request to Cloud Registrar

### Cloud Registrar Discovery

BRSKI defines how a Pledge MAY contact a well-known URI of a Cloud Registrar if a local domain Registrar cannot be discovered.
Additionally, certain Pledge types might never attempt to discover a local domain Registrar and might automatically bootstrap against a Cloud Registrar.

The details of the URI are manufacturer specific, with BRSKI giving the example "brski-registrar.manufacturer.example.com".

The Pledge SHOULD be provided with the entire URI of the Cloud Registrar, including the protocol and path components, which are typically "https://" and "/.well-known/brski", respectively.

### Pledge - Cloud Registrar TLS Establishment Details

According to {{BRSKI, Section 2.7}}, the Pledge MUST use an Implicit Trust Anchor database (see EST {{!RFC7030}}) to authenticate the Cloud Registrar service.
The Pledge MUST establish a mutually authenticated TLS connection with the Cloud Registrar.
Unlike the Provisional TLS procedures documented in {{BRSKI, Section 5.1}}, the Pledge MUST NOT establish a Provisional TLS connection with the Cloud Registrar.

Pledges MUST and Cloud/Owner Registrars SHOULD support the use of the "server\_name" TLS extension (SNI, [RFC6066]) when using TLS 1.2.
Support for SNI is mandatory with TLS 1.3.

Pledges SHOULD send a valid "server\_name" extension (SNI) whenever they know the domain name of the registrar they connect to.
A Pledge creating a Provisional TLS connection according to {{BRSKI}} will often only know the IPv6 link local IP address of a Join Proxy that connects it to the Registrar.
Registrars are accordingly expected to ignore SNI information, as in most cases, the Pledge will not know how to set the SNI correctly.

The Pledge MUST be manufactured with pre-loaded trust anchors that are used to verify the identity of the Cloud Registrar when establishing the TLS connection.
The TLS connection can be verified using a public Web PKI trust anchor using {{RFC9525}} DNS-ID mechanisms or a pinned certification authority.
This is a local implementation decision.
Refer to {{trust-anchors-for-cloud-registrar}} for trust anchor security considerations.

The Cloud Registrar MUST verify the identity of the Pledge by sending a TLS CertificateRequest message to the Pledge during TLS session establishment.
The Cloud Registrar MAY include a certificate_authorities field in the message to specify the set of allowed IDevID issuing CAs that Pledges may use when establishing connections with the Cloud Registrar.

To protect itself against DoS attacks, the Cloud Registrar SHOULD reject TLS connections when it can determine during TLS authentication that it cannot support the Pledge, for example because the Pledge cannot provide an IDevID signed by a CA recognized/supported by the Cloud Registrar.

### Pledge Sends Voucher Request Message

After the Pledge has established a mutually authenticated TLS connection with the Cloud Registrar, the Pledge generates a voucher request message as outlined in BRSKI section 5.2, and sends the voucher request message to the Cloud Registrar.

## Cloud Registrar Processes Voucher Request Message

The Cloud Registrar must determine Pledge ownership.
Prior to ownership determination, the Registrar checks the request for correctness and if it is unwilling or unable to handle the request, it MUST return a suitable 4xx or 5xx error response to the Pledge as defined by {{BRSKI}} and HTTP.
The Registrar returns the following errors:

* in the case of an unknown Pledge, a 404 is returned,
* for a malformed request, 400 is returned
* in case of server overload, 503 is returned.

If the request is correct and the Registrar is able to handle it, but unable to determine ownership at that time, then it MUST return a 401 Unauthorized response to the Pledge.
This signals to the Pledge that there is currently no known owner domain for it, but that retrying later might resolve this situation.
In this scenario, the Registrar SHOULD include a Retry-After header that includes a time to defer.
The absense of a Retry-After header indicates to the Pledge not to attempt again.
The Pledge MUST restart the bootstrapping process from the beginning.

A Pledge with some kind of indicator (such as a screen or LED) SHOULD consider all 4xx and 5xx errors to be a bootstrapping failure, and indicate this to the operator.

If the Cloud Registrar successfully determines ownership, then it MUST take one of the following actions:

* error: return a suitable 4xx or 5xx error response (as defined by [BRSKI] and HTTP) to the Pledge if the request processing failed for any reason
* redirect to Owner Registrar: redirect the Pledge to an Owner Registrar via 307 response code
* redirect to owner EST server: issue a voucher (containing an est-domain attribute) and return a 200 response code

### Pledge Ownership Look Up {#PledgeOwnershipLookup}

The Cloud Registrar needs some suitable mechanism for knowing the correct owner of a connecting Pledge based on the presented identity certificate.
For example, if the Pledge establishes TLS using an IDevID that is signed by a known manufacturing CA, the Registrar could extract the serial number from the IDevID and use this to look up a database of Pledge IDevID serial numbers to owners.

The mechanism by which the Cloud Registrar determines Pledge ownership is, however, outside the scope of this document.
The Cloud Registrar is strongly tied to the manufacturers' processes for device identity.

### Bootstrap via Cloud Registrar and Owner Registrar

Once the Cloud Registrar has determined Pledge ownership, the Cloud Registrar MAY redirect the Pledge to the Owner Registrar in order to complete bootstrap.
If the owner wants the Cloud Registrar to redirect Pledges to their Owner Registrar, the owner must register their Owner Registrar URI with cloud Registrar.
The mechanism by which Pledge owners register their Owner Registrar URI with the Cloud Registrar is outside the scope of this document.

In case of redirection, the Cloud Registrar replies to the voucher request with an HTTP 307 Temporary Redirect response code, including the owner's local domain in the HTTP Location header.

### Bootstrap via Cloud Registrar and Owner EST Service

If the Cloud Registrar issues a voucher, it returns the voucher in an HTTP response with a 200 response code.

The Cloud Registrar MAY issue a 202 response code if it is willing to issue a voucher, but will take some time to prepare the voucher.

The voucher MUST include the new "est-domain" field as defined in {{RFC8366bis}}.
This tells the Pledge where the domain of the EST service to use for completing certificate enrollment.

The voucher MAY include the new "additional-configuration" field.
This field points the Pledge to a URI where Pledge specific additional configuration information may be retrieved.
For example, a SIP phone might retrieve a manufacturer specific configuration file that contains information about how to do SIP Registration.
One advantage of this mechanism over current mechanisms like DHCP options 120 defined in {{?RFC3361}} or option 125 defined in {{?RFC3925}} is that the voucher is returned in a confidential (TLS-protected) transport, and so can include device-specific credentials for retrieval of the configuration.

The exact Pledge and Registrar behavior for handling and specifying the "additional-configuration" field is outside the scope of this document.


## Pledge Handles Cloud Registrar Response

### Bootstrap via Cloud Registrar and Owner Registrar {#redirect-response}

The Cloud Registrar has returned a 307 response to a voucher request.
The Cloud Registrar may be redirecting the Pledge to the Owner Registrar, or to a different Cloud Registrar operated by a VAR.

The Pledge MUST restart its bootstrapping process by sending a new voucher
request message (with a fresh nonce) using the location provided in the HTTP redirect.

The Pledge SHOULD attempt to validate the identity of the Cloud VAR Registrar specified in the 307 response using its Implicit Trust Anchor Database.
If validation of this identity succeeds using the Implicit Trust Anchor Database, then the Pledge MAY accept a subsequent 307 response from this Cloud VAR Registrar.

The Pledge MAY continue to follow a number of 307 redirects provided that each 307 redirect target Registrar identity is validated using the Implicit Trust Anchor Database.

However, if validation of a 307 redirect target Registrar identity using the Implicit Trust Anchor Database fails, then the Pledge MUST NOT accept any further 307 responses from the Registrar.
At this point, the TLS connection that has been established is considered a Provisional TLS, as per {{BRSKI, Section 5.1}}.
The Pledge then (re)sends a voucher-request on this connection.
This connection is validated using the pinned data from the voucher, which is the standard BRSKI mechanism.

The Pledge MUST process any error messages as defined in {{BRSKI}}, and in case of error MUST restart the process from its provisioned Cloud Registrar.
The exception is that a 401 Unauthorized code SHOULD cause the Pledge to retry a number of times over a period of a few hours.

In order to avoid permanent bootstrap cycles, the Pledge MUST NOT revisit a prior location.
{{multiplehttpredirects}} further outlines risks associated with redirects.
However, in some scenarios, Pledges MAY visit the current location multiple times, for example when handling a 401 Unauthorized response, or when handling a 503 Service Unavailable that includes a Retry-After HTTP header.
If it happens that a location is repeated, then the Pledge MUST fail the bootstrapping attempt and go back to the beginning, which includes listening to other sources of bootstrapping information as specified in {{BRSKI}} section 4.1 and 5.0.
The Pledge MUST also have a limit on the total number of redirects it will a follow, as the cycle detection requires that it keep track of the places it has been.
That limit MUST be in the dozens or more redirects such that no reasonable delegation path would be affected.

When the Pledge cannot validate the connection, then it MUST establish a Provisional TLS connection with the specified local domain Registrar at the location specified.

The Pledge then sends a voucher request message via the local domain Registrar.

After the Pledge receives the voucher, it verifies the TLS connection to the local domain Registrar and continues with enrollment and bootstrap as per standard BRSKI operation.

The Pledge MUST process any error messages as defined in {{BRSKI}}, and in case of error MUST restart the process from its provisioned Cloud Registrar.

The exception is that a 401 Unauthorized code SHOULD cause the Pledge to retry a number of times over a period of a few hours.

### Bootstrap via Cloud Registrar and Owner EST Service

The Cloud Registrar returned a voucher to the Pledge.
The Pledge MUST perform voucher verification as per BRSKI section 5.6.1.

The Pledge SHOULD extract the "est-domain" field from the voucher, and SHOULD continue with EST enrollment as per standard EST operation. Note that the Pledge has been instructed to connect to the EST server specified in the "est-domain" field, and therefore SHOULD use EST mechanisms, and not BRSKI mechanisms, when connecting to the EST server.

# Protocol Details


## Bootstrap via Cloud Registrar and Owner Registrar {#redirect2Registrar}

This flow illustrates the "Bootstrap via Cloud Registrar and Owner Registrar" use case.
A Pledge is bootstrapping in a remote location with no local domain Registrar.
The assumption is that the Owner Registrar domain is accessible, and the Pledge can establish a network connection with the Owner Registrar.
This may require that the owner network firewall exposes the Owner Registrar on the public internet.

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
    |                                                 |
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
    | 10. etc.             |
    |--------------------->|
    |                      |
~~~

The process starts, in step 1, when the Pledge establishes a Mutual TLS channel with the Cloud Registrar using artifacts created during the manufacturing process of the Pledge.

In step 2, the Pledge sends a voucher request to the Cloud Registrar.

The Cloud Registrar determines Pledge ownership look up as outlined in {{PledgeOwnershipLookup}}, and determines the Owner Registrar domain.
In step 3, the Cloud Registrar redirects the Pledge to the Owner Registrar domain.

Steps 4 and onwards follow the standard BRSKI flow.
The Pledge establishes a Provisional TLS connection with the Owner Registrar, and sends a voucher request to the Owner Registrar.
The Registrar forwards the voucher request to the MASA.
Assuming the MASA issues a voucher, then the Pledge verifies the TLS connection with the Registrar using the pinned-domain-cert from the voucher and completes the BRSKI flow.

## Bootstrap via Cloud Registrar and Owner EST Service {#voucher2EST}

This flow illustrates the "Bootstrap via Cloud Registrar and Owner EST Service" use case.
A Pledge is bootstrapping in a location with no local domain Registrar.
The Cloud Registrar is instructing the Pledge to connect directly to an EST server for enrollment using EST mechanisms.
The assumption is that the EST domain is accessible, and the Pledge can establish a network connection with the EST server.

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
    | 6. EST Enroll        |                          |
    |--------------------->|                          |
    |                      |                          |
    | 7. Certificate       |                          |
    |<---------------------|                          |
    |                      |                          |
    | 8. /enrollstatus     |                          |
    |--------------------->|                          |
~~~

The process starts, in step 1, when the Pledge establishes a Mutual TLS channel with the Cloud Registrar/MASA using artifacts created during the manufacturing process of the Pledge.

In step 2, the Pledge sends a voucher request to the Cloud Registrar/MASA.

In step 3, the the Cloud Registrar/MASA replies to the Pledge with an {{RFC8366bis}} format voucher that includes its assigned EST domain in the est-domain attribute.

In step 4, the Pledge establishes a TLS connection with the EST RA specified in the voucher est-domain attribute.
The connection may involve crossing the Internet requiring a DNS look up on the provided name.
It may also be a local address that includes an IP address literal including both IPv4 {{?RFC1918}} and IPv6 Unique Local Addresses {{?RFC4193}}.
The artifact provided in the pinned-domain-cert is trusted as a trust anchor, and is used to verify the EST server identity.
The EST server identity MUST be verified using the pinned-domain-cert value provided in the voucher as described in {{?RFC7030}} section 3.3.1.

There is a case where the pinned-domain-cert is the identical End-Entity (EE) Certificate as the EST server.
It also explicitly includes the case where the EST server has a self-signed EE Certificate, but it may also be an EE certificate that is part of a larger PKI.
If the certificate is not a self-signed or EE certificate, then the Pledge SHOULD apply {{RFC9525}} DNS-ID verification on the certificate against the domain provided in the est-domain attribute.
If the est-domain was provided with an IP address literal, then it is unlikely that it can be verified, and in that case, it is expected that either a self-signed certificate or an EE certificate will be pinned by the voucher.

The Pledge also has the details it needs to be able to create the CSR request to send to the RA based on the details provided in the voucher.

In steps 5.a and 5.b, the Pledge may optionally notify the Cloud Registrar/MASA of the success or failure of its attempt to establish a secure TLS channel with the EST server.

In step 6, the Pledge sends an EST Enroll request with the CSR.

In step 7, the EST server returns the requested certificate. The Pledge must verify that the issued certificate has the expected identifier obtained from the Cloud Registrar/MASA in step 3.

# Lifecycle Considerations

BRSKI and the Cloud Registrar support provided in this document are dependent upon the manufacturer maintaining the required infrastructure.

{{BRSKI, Section 10.7}} and Section 11.5 and 11.6 detail some additional considerations about device vs manufacturer life span.

The well-known URL that is used is specified by the manufacturer when designing its firmware, and is therefore completely under the manufacturer's control.
If the manufacturer wishes to change the URL, or discontinue the service, then the manufacturer will need to arrange for a firmware update where appropriate changes are made.

# IANA Considerations

This document makes no IANA requests.

# Implementation Considerations

## Captive Portals

A Pledge may be deployed in a network where a captive portal or an intelligent home gateway that provides access control on all connections is also deployed.
Captive portals that do not follow the requirements of {{?RFC8952}} section 1 may forcibly redirect HTTPS connections.
While this is a deprecated practice as it breaks TLS in a way that most users can not deal with, it is still common in many networks.

When the Pledge attempts to connect to the Cloud Registrar, an incorrect connection will be detected because the Pledge will be unable to verify the TLS connection to its Cloud Registrar via DNS-ID check {{?RFC9525, Section 6.3}}.
That is, the certificate returned from the captive portal will not match.

At this point a network operator who controls the captive portal, noticing the connection to what seems a legitimate destination (the Cloud Registrar), may then permit that connection.
This enables the first connection to go through.

The connection is then redirected to the Registrar via 307, or to an EST server via est-domain in a voucher.
If it is a 307 redirect, then a Provisional TLS connection will be initiated, and it will succeed.
The Provisional TLS connection does not do {{RFC9525, Section 6.3}} DNS-ID verification at the beginning of the connection, so a forced redirection to a captive portal system will not be detected.
The subsequent BRSKI POST of a voucher will most likely be met by a 404 or 500 HTTP code.

It is RECOMMENDED therefore that the Pledge look for {{?RFC8910}} attributes in DHCP, and if present, use the {{?RFC8908}} API to learn if it is captive.

The scenarios outlined here when a Pledge is deployed behind a captive portal may result in failure scenarios, but do not constitute a security risk, as the Pledge is correctly verifying all TLS connections as per {{BRSKI}}.

## Multiple HTTP Redirects {#multiplehttpredirects}

If the Redirect to Registrar method is used, as described in {{redirect2Registrar}}, there may be a series of 307 redirects.
An example of why this might occur is that the manufacturer only knows that it resold the device to a particular value added reseller (VAR), and there may be a chain of such VARs.
It is important the Pledge avoid being drawn into a loop of redirects.
This could happen if a VAR does not think they are authoritative for a particular device.
A "helpful" programmer might instead decide to redirect back to the manufacturer in an attempt to restart at the top:  perhaps there is another process that updates the manufacturer's database and this process is underway.
Instead, the VAR MUST return a 404 error if it cannot process the device.
This will force the device to stop, timeout, and then try all mechanisms again.

There are additional considerations regarding TLS certificate validation that must be accounted for as outlined in {{redirect-response}}.
When the Pledge follows a 307 redirect from the default Cloud Registrar, it will attempt to establish a TLS connection with the redirected target Registrar.
The Pledge implementation will typically register a callback with the TLS stack, where the TLS stack allows the implementation to validate the identity of the Registrar.
The Pledge should check whether the identity of the Registrar can be validated with its Implicit Trust Anchor Database and track the result, but should always return a successful validation result to the TLS stack, thus allowing the {{BRSKI}} Provisional TLS connection to be established.
The Pledge will then send a Voucher Request to the Registrar.
If the Registrar returns a 307 response, the Pledge MUST NOT follow this redirect if the Registrar identity was not validated using its Implicit Trust Anchor Database.
If the Registrar identity was validated using the Implicit Trust Anchor Database, then the Pledge MAY follow the redirect.

# Security Considerations

The Cloud Registrar described in this document inherits all the strong security properties that are described in {{BRSKI}}, and none of the security mechanisms that are defined in {{BRSKI}} are bypassed or weakened by this document.
The Cloud Registrar also inherits all the potential issues that are described in {{BRSKI}}.
This includes dependency upon continued operation of the manufacturer provided MASA, as well as potential complications where a manufacturer might interfere with
resale of a device.

In addition to the dependency upon the MASA, the successful enrollment of a device using a Cloud Registrar depends upon the correct and continued operation of this new service.
This internet accessible service may be operated by the manufacturer and/or by one or more value-added-resellers.
All the considerations for operation of the MASA also apply to operation of the Cloud Registrar.

## Security Updates for the Pledge

Unlike many other uses of BRSKI, in the Cloud Registrar case it is assumed that the Pledge has connected to a network, such as the public Internet, on which some amount of connectivity is possible, but there is no other local configuration available.
(Note: there are many possible configurations in which the device might not have unlimited connectivity to the public Internet, but for which there might be connectivity possible.
For instance, the device could be without a default route or NAT44, but able to make HTTP requests via an HTTP proxy configured via DHCP)

There is another advantage to being online: the Pledge may be able to contact the manufacturer before bootstrapping in order to apply the latest firmware updates.
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

The Pledge may have any kind of Trust Anchor built in: from full multi-level WebPKI to the single self-signed certificate used by the Cloud Registrar.
There are many tradeoffs to having more or less of the PKI present in the Pledge, which is addressed in part in {{?I-D.irtf-t2trg-taxonomy-manufacturer-anchors}} in sections 3 and 5.

## Considerations for HTTP Redirect {#considerationsfor-http-redirect}

When the default Cloud Registrar redirects a Pledge using HTTP 307 to an Owner Registrar, or another Cloud Registrar operated by a VAR, the Pledge MUST establish a Provisional TLS connection with the Registrar as specified in {{BRSKI}}.
The Pledge will be unable to determine whether it has been redirected to another Cloud Registrar that is operated by a VAR, or if it has been redirected to an Owner Registrar at this stage.
The determination needs to be made based upon whether or not the Pledge is able to validate the certificate for the new server.
If the pledge can not validate, then the connection is considered a provisional connection.

## Considerations for Voucher est-domain

A Cloud Registrar supporting the same set of Pledges as a MASA may be integrated with the MASA to avoid the need for a network based API between them, and without changing their external behavior as specified here.

When a Cloud Registrar handles the scenario described in {bootstrapping-with-no-owner-registrar} by the returning "est-domain" attribute in the voucher, the Cloud Registrar actually does all the voucher processing as specified in {{BRSKI}}.
This is an example deployment scenario where the Cloud Registrar may be operated by the same entity as the MASA, and it may even be integrated with the MASA.

When a voucher is issued by the Cloud Registrar and that voucher contains an "est-domain" attribute, the Pledge MUST verify the TLS connection with this EST server using the "pinned-domain-cert" attribute in the voucher.

The reduced operational security mechanisms outlined in {{BRSKI}} sections 7.3 and 11 MAY be supported when the Pledge connects with the EST server.
These mechanisms reduce the security checks that take place when the Pledge enrolls with the EST server.
Refer to {{BRSKI}} sections 7.3 and 11 for further details.

# Acknowledgements
{: numbered="no"}

The authors would like to thank for following for their detailed reviews: (ordered
by last name): Esko Dijk, Toerless Eckert, Sheng Jiang.


