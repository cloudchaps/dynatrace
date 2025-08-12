    # Example Dockerfile for an Ansible image
    FROM ubuntu:latest

    RUN apt-get update && \
        apt-get install -y python3 python3-pip && \
        pip3 install ansible

    # Set the entrypoint to ansible-playbook or a shell
    # ENTRYPOINT ["ansible-playbook"]
    # CMD ["--version"]