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
