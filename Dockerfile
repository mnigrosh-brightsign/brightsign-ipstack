# I used snyk to find the most recent (as of 10 Dec 2023) version of Python
# that had the fewest known vulnerabilities and the smallest footprint.
# https://snyk.io/advisor/docker/python
FROM python:3.13.0a2-slim

# Unless we intervene, the whole container is going to run as root. If
# there's some sort of injection attack, that's bad news for our container.
# Make an unprivileged user.
RUN groupadd -g 999 brightsign && \
    useradd -r -u 999 -g brightsign brightsign

# Create the running directory and transfer ownership.
RUN mkdir /usr/local/app
RUN chown brightsign:brightsign /usr/local/app
WORKDIR  /usr/local/app

# Make sure anything we need will be on the new container.
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY --chown=brightsign:brightsign ip_latlong.py .

USER 999

ARG BUILDTIME_API_KEY=default
ENV API_KEY=$BUILDTIME_API_KEY

ENTRYPOINT ["python3", "ip_latlong.py"]
