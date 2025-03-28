# Use the specified Eclipse Temurin Java 11 JDK base image (Ubuntu Bionic)
FROM eclipse-temurin:11.0.26_4-jdk

# Overwrite the APT sources list with the full official Ubuntu Bionic repositories
RUN echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Add the missing GPG key for the Ubuntu Bionic repositories
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32

# Update and install required packages including libraries, Xvfb, x11vnc, websockify and noVNC
RUN apt-get update && apt-get install -y \
    lsb-release \
    libwebkitgtk-1.0-0 \
    libgtk2.0-0 \
    shared-mime-info \
    unzip \
    wget \
    xvfb \
    x11vnc \
    websockify \
    novnc \
    && rm -rf /var/lib/apt/lists/*

# Set the Pentaho Data Integration installation directory and update PATH
ENV PDI_HOME=/opt/data-integration
ENV PATH=$PDI_HOME:$PATH

# Copy the Pentaho Data Integration (PDI) zip file into the container.
COPY pdi-ce-10.2.0.0-222.zip /tmp/pdi-ce.zip

# Unzip the PDI files and clean up the zip file
RUN unzip /tmp/pdi-ce.zip -d /opt/ && \
    rm /tmp/pdi-ce.zip

# Download the PostgreSQL JDBC driver (adjust URL/version as needed)
RUN wget -O $PDI_HOME/lib/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.5.0.jar

# Copy the Oracle JDBC driver (ensure that 'ojdbc8.jar' is in your build context)
COPY ojdbc8.jar $PDI_HOME/lib/

# Copy your Carte configuration file to the proper location
COPY carte-config.xml $PDI_HOME/carte-config.xml

# Copy the updated entrypoint script and mark it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the Carte server port (default 8080) and noVNC port (6080)
EXPOSE 8080
EXPOSE 6080

# Set the entrypoint to our script that starts the graphical stack and then runs spoon.sh
ENTRYPOINT ["/entrypoint.sh"]
