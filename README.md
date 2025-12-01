# AnyVM Docker

Run AnyVM images inside Docker to spin up throwaway VMs for different OS targets.

## 1. Quick start
```sh
docker run --rm -it ghcr.io/anyvm-org/anyvm --os freebsd
```
Replace `--os freebsd` with the OS you want to boot.

## 2. Mount a host folder into the VM
```sh
mkdir -p test
docker run --rm -it \
  -v $(pwd)/test:/mnt/host \
  ghcr.io/anyvm-org/anyvm --os freebsd
```

## 3. Expose VM ports to the host
```sh
docker run --rm -it \
  -p 10022:10022 \
  ghcr.io/anyvm-org/anyvm --os freebsd
```
Default VM SSH port is `10022`.

## 4. Forward host traffic into the VM
```sh
docker run --rm -it \
  -p 8080:8080 \
  ghcr.io/anyvm-org/anyvm --os freebsd -p 8080:80
```
The first `-p` publishes container port 8080 to the host; the second forwards container 8080 to VM port 80.

## 5. Send a command via SSH with `--`
Use `--` to separate AnyVM arguments from a command you want executed via your SSH handler. Args after `--` are executed in the VM.
```sh

docker run --rm -it ghcr.io/anyvm-org/anyvm --os freebsd -- uname -a




mkdir -p test
echo "text in host" >test/host.txt

docker run --rm -it \
  -v $(pwd)/test:/mnt/host \
  ghcr.io/anyvm-org/anyvm --os freebsd -- ls /mnt/host



```


## 6. More info
See the [anyvm](https://github.com/anyvm-org/anyvm) project for available OS targets and options.
