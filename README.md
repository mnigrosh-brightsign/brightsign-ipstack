# brightsign-ipstack
BrightSign IPStack Project

## Usage
This script is intended to work on all major MacOS and Linux distributions.
One can invoke directly it by doing:
```
python3 ip_latlong.py <ip>
```
where `<ip>` is the IP address to query.
A successful execution of this program will result in the output of the
latitude and longitude coordinated for the IP address, and an exit code of 0.
All other exit codes indicate failure.

However, if invoking the script this way, the user must supply an IPStack API
key as an environment variable in the local environment. It must be named
API_KEY.
One could possibly do this by setting that value on the command line, such as
```
export API_KEY=<API key>
```
or, for those who may not use `bash` as their default shell,
```
setenv API_KEY <API key>
```
where `<API key>` is the user's API key, that may look like
`ef58ffee79f24819903092265793d0d4` (this is not a known IPStack API key).

## Running in `docker`
This program is also provided as a docker image which can be found at
[ip_latlong-docker_image.tar.gz](ip_latlong-docker_image.tar.gz).
It is assumed that the user has a working docker installation. For more
information about installing docker see [Install Docker Engine](https://docs.docker.com/engine/install/) and, possibly [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).
In order to run the program through docker, one can do the following:
```
docker load < ip_latlong-docker_image.tar.gz
docker run ip_latlong <test_ip>
```
where `<test_ip>` is the IP address to query.

## Documentation
This code uses `doxygen` for documentation. The generated files are not
included in this repo, as they are many and large and not everyone wishes to
read them. One can clone this repo and run `make doc` in order to generate LaTeX
and HTML documentation. This requires having `doxygen` installed.

## Assumptions and Invariants
- There shall only be a single parameter passed on the command line.
- The IP address shall be in dotted-quad format or in colon-separated format.
Though other formats exist, such as decimal or binary, it seems as though
IPStack does not accept those. They do accept octal IP addresses, but this code
does not, as they are too similar to dotted-quads. IPStack *does* seem to
accept FQDNs as input, but, as this project specifically states "IP addresses",
those shall not be considered valid inputs.
- The latitude and longitude shall be output in a coordinate format at the
command line, such as `(<latitude>, <longitude>)`.  All latitude and longitude
values shall be rounded to four (4) decimal places.  This is intended to meet
the "some useful way" requirement.
- This software shall run on Linux and MacOS, but its behaviour is unspecified
for any other operating system. It has only been tested on MacOS Ventura,
MacOS Sonoma, Ubuntu 20.04, and CentOS 7. The author uses `tcsh` instead of
`bash` as the default shell and is, indeed, evangelical about it.
- In the docker case, it is assumed that target systems shall have a configured
and running docker daemon. Individual installation, configuration, and
licensing of docker is beyond the scope of this project.
- In the docker case, it is assumed that the docker daemon shall be running.

## Contents of This Directory
.env.SAMPLE:
A sample environment file used for building docker images.
</br>

.flake8:
Lint configuration for Flake8 Pythone linter.
</br>

Dockerfile:
Instructional file used to build a docker image of this program.
</br>

Makefile:
Makefile for doing various steps in the process of manipulating this code.
Can be used to create the docker image, to generate documentation, to operate
on python requirements, etc.
</br>

doxy.config:
Configuration for `doxygen`. The actual generated documentation is not
included in this repository, due to its size, but one can easily run `make doc`
and then navigate to the local HTML or LaTeX documentation that has been
generated.
</br>

ip_latlong-docker_image.tar.gz:
Tarball of the docker image created for this program.
</br>

ip_latlong.py:
Python program that accepts a single argument on the command line and attempts
to resolve that IP address into a set of latitude and longitude coordinates on
a world map, using IPStack's API.
</br>

requirements.txt:
Python requirements file. Needed for making the docker image and as a helpful
reference for anyone trying to run the `ip_latlong.py` program.
</br>

test_input_word_bank:
Some values to copy-paste onto the command line in order to test `ip_latlong.py`
</br>

## On Security
### API Keys
One of the requirements for this project was to create a free tier account with
IPStack. In order to access their API, one needs an API key. This token
could be compromised and would allow a malicious actor to impersonate the
account holder.
Because of that, the API key is not included in this git repository, and effort
has been made to conceal it from a docker user. The API key is only provided
to docker at build time, and, even so, is only done by parsing a file.

Of course, since the free tier is only allowed to use HTTP as a scheme, one
could easily sniff the traffic in order to discover the API key being used.

### Spoofing IPStack
There are a number of different threat vectors arriving from a cybercrook
spoofing IPStack. Since this projects limits us to the free tier of IPStack,
and since IPStack does not make HTTPS requests available to free accounts,
we lose some of the inherent safety of secure requests.
Were we able to use HTTPS, we could validate the TLS certificates of the
website purporting to be IPStack.
#### Going After the API Key, Again
Since the way one contacts IPStack is by providing an API key in the URL, a
nefarious individual basically wins if we send them a request. There's not
much we can do about this, short of petitioning IPStack to change their API.
#### Providing An Unexpectedly Large Response
There's a cool denial-of-service attack a hacker could complete on us by
returning an extremely large response. One approach to parsing JSON objects
is to read the entire thing into memory first, and it would be possible to
run a target machine out of resources with a sufficiently-sized payload.
Because of that, this implementation uses streamed GET requests and iterates
through their content in small chunks, placing a limit on the total number of
octets that can be received. A possible addition would be to also start a timer
that looks at how long it takes to process each of these chunks.

### Docker
Another threat vector would be to provide a fake docker image in the main
docker library with the same name as this one. This program could have taken
advantage of `docker images --digests` and provided some test scripts in this
repository.

### Git
One of the requirements for this project was that it be in a public git
repository on GitHub. Were this to become production code, it should be moved
to a private repository. For now, all of the branches are locked so at least
no one else can contribute to it, but that does not protect against all attacks.

## Optimizations and Future Modifications
### File Storage
This project does not use git-LFS, though an export of the docker image file is
stored in the git repo. This is because installing git-LFS has been known
troublesome for some systems and may result in incompatible `pull` and `push`
operations. If this were to become production code, we could use git-LFS, but
it may make more sense not to store the docker image in git in the first place.
We could use Artifactory, or Google Drive, or something similar.
### Usage Tracking and Rate Limiting
Free IPStack accounts only get 1000 lookups per month, and we have made the
assumption that that is good enough for this project. A possible addition would
be to add a tool that tracks how many requests remain for the current month.
### Global Variables
This code includes a number of global variables, such as `QUERY_FIELDS`,
`REQUEST_TIMEOUT` and `DEFAULT_LAT_LONG_PRECISION`. These are listed as
global constants so that they can be easily manipulated without delving into
the code. They could, however, be placed in an environment file and altered
without any need to open the Python file.
### Retries and Persistence
As written, this program does not make particularly vigorous effort to contact
the IPStack servers. We could add a Session object that could support
retries, backoff factors, and even pool connections.
### Logging and Output
This program only prints to stdout when there is a successful match for an
IP address. It uses logging in a very basic manner--largely to separate messages
going to stderr from those intended to go to stdout. It could be modified to
log messages to a file, or to syslog, or it could expose them over the network.
### Testing
Testing for this program was done via manual input using a copy-paste bank
in the [test_input_word_bank](test_input_word_bank) file. We could have used
`pytest`. We definitely would if this were production. There was some fear
about doing any significant automation, given the constraint of 1000 requests
per month on a free account and the desire to allow others to use the same API
key once they copy the docker container.
