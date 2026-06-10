# Manual setup vscode connection with vm

If you struggle to get connection with vscode through ssh tunnel, it might be because your VM's proxy cannot access the download page of VSCode. 
To still be able to use VSCode with your VM you need to install the latest commit version on your machine. 
To do this you need to clone this repository and then run the run.sh script. 

1. clone repo
2. run:

```bash
cd .initvscode
chmod +x run.sh
sudo bash run.sh
```

3. test connection with vscode

> The `vscode-server-linux-x64.tar.gz` is no longer committed to the repo (it
> exceeds GitHub's 100 MB file limit). A daily GitHub Action publishes it as the
> asset of the `latest` release, and `run.sh` downloads it automatically if it
> isn't already present. The VM therefore needs to reach
> `github.com`/release downloads, but still not VSCode's own update CDN.
