FROM ubuntu:latest
RUN apt-get update ; apt-get install -y fortune
ADD fortune.sh /bin/fortune.sh
RUN chmod +x /bin/fortune.sh

CMD ["10"]
ENTRYPOINT ["/bin/fortune.sh"]