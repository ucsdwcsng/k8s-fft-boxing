FROM wcsng-36.ucsd.edu/matlab:u20.04_m2022a_july29

ARG USER=scisrs
ARG USERDIR=/home/${USER}

RUN adduser --disabled-password --gecos "" ${USER}

RUN mkdir ${USERDIR}/fft_boxing

COPY --chown=${USER} searchlight ${USERDIR}/fft_boxing/searchlight

COPY --chown=${USER} . ${USERDIR}/fft_boxing

USER ${USER}
WORKDIR ${USERDIR}/fft_boxing