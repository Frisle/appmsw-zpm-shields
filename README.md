![](https://raw.githubusercontent.com/SergeyMi37/appmsw-zpm-shields/master/doc/Screenshot_1.png)
## zpm-shields
[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/appmsw-zpm-shields)
[![DC](https://img.shields.io/badge/Available%20article%20on-Intersystems%20Community-orange)](https://community.intersystems.com/post/deploying-solutions-without-source-code-zpm)
[![GitHub all releases](https://img.shields.io/badge/Available%20on-GitHub-black)](https://github.com/SergeyMi37/appmsw-zpm-shields)
 
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=sergeymi37%2Fappmsw-zpm-shields&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=sergeymi37%2Fappmsw-zpm-shields)
 <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/SergeyMi37/appmsw-zpm-shields">
 [![license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

 [![](https://ee2c-109-252-71-113.ngrok.io/zpm-shields/both/mode?module=sergeymi37%2Fappmsw-zpm-shields&project=zpm-shields)
   
 
You can ...

## Installation with ZPM

If ZPM the current instance is not installed, then in one line you can install the latest version of ZPM.
```
set $namespace="%SYS", name="DefaultSSL" do:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name) set url="https://pm.community.intersystems.com/packages/zpm/latest/installer" Do ##class(%Net.URLParser).Parse(url,.comp) set ht = ##class(%Net.HttpRequest).%New(), ht.Server = comp("host"), ht.Port = 443, ht.Https=1, ht.SSLConfiguration=name, st=ht.Get(comp("path")) quit:'st $System.Status.GetErrorText(st) set xml=##class(%File).TempFilename("xml"), tFile = ##class(%Stream.FileBinary).%New(), tFile.Filename = xml do tFile.CopyFromAndSave(ht.HttpResponse.Data) do ht.%Close(), $system.OBJ.Load(xml,"ck") do ##class(%File).Delete(xml)
```
If ZPM is installed, then `appmsw-dbdeploy` can be set with the command
```
zpm:USER>install appmsw-dbdeploy
```
## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
git clone https://github.com/SergeyMi37/appmsw-zpm-shields
```

Open the terminal in this directory and run:

```
docker-compose build
```

3. Run the IRIS container with your project:

```
docker-compose up -d
```

## 
```
docker-compose exec iris iris session iris
```

