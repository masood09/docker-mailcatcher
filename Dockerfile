# Use phusion/baseimage as base image.
FROM phusion/baseimage:0.9.17

# Set some metadata
LABEL version="0.6.1"
LABEL description="Docker container for MailCatcher (http://mailcatcher.me/). The container exposes port 1025 and 1080."

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so we
# have to do that yourself.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Gerenare the locales
RUN locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8

# Update & upgrade the repositories
RUN apt-get update
RUN apt-get -y --force-yes upgrade

# Install Mailcatcher (0.6.1)
RUN apt-get -y --force-yes install build-essential libsqlite3-dev ruby-dev
RUN gem install --no-rdoc --no-ri mailcatcher

# Copy the init files for Mailcacher
ADD build/99_mailcatcher.sh /etc/my_init.d/99_mailcatcher.sh
RUN chmod +x /etc/my_init.d/99_mailcatcher.sh

# Make the port 1025 and 1085 available to outside world
EXPOSE 1025
EXPOSE 1080

# Deleting the man pages and documentation
RUN find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
RUN find /usr/share/doc -empty|xargs rmdir || true
RUN rm -rf /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian > /usr/share/linda /var/cache/man

# Clean up APT when done.
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
