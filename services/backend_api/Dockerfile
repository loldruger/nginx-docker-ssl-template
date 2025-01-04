FROM rust
COPY . /home/work
WORKDIR /home/work
RUN cargo build
CMD ["./target/debug/backend_api"]
ENTRYPOINT ["tail", "-f", "/dev/null"]