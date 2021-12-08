/// Added shields to README.MD file repository
/// [![RepoZPM](http://hostserver/zpm-shields/repo/mode?module=sergeymi37%2Fappmsw-dbdeploy&color=gold)
/// [![RegZPM](http://hostserver/zpm-shields/both/mode?module=sergeymi37%2Fappmsw-dbdeploy&project=appmsw-dbdeploy&color=gold)
/// [![Repo+RegZPM](http://hostserver/zpm-shields/both/mode?module=rcemper%2Fzpmshow&project=zpmshow)
Class dc.appmsw.shields Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/testget/:text" Method="GET" Call="Test"/>  
<Route Url="/repo/:url" Method="GET" Call="GetZpmVersion"/>
<Route Url="/registry/:url" Method="GET" Call="GetZpmVersion"/>
<Route Url="/both/:url" Method="GET" Call="GetZpmVersion"/>
</Routes>
}

ClassMethod Test(parameter) As %Status
{
	set %response.CharSet = "utf-8"
    set %response.ContentType = "text/html"
	&html<<h1>Status: OK!</h1><pre>>
	zw %request
	set i=""
	for { set i=$o(%request.Data(i)) quit:i=""
		set:$o(%request.Data(i,""),-1)'="" Par("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
	}
	zw Par
	zw %response
	&html<</pre>>
	quit $$$OK
}

/// Search numbers versions ZPM and OEX registry
/// http://localhost:52773/zpm-shields/repo/mode?module=https:%2F%2Fgithub.com%2FSergeyMi37%2Fzapm&color=blue&debug=1
/// http://localhost:52773/zpm-shields/repo/mode?module=sergeymi37%2Fappmsw-dbdeploy&color=gold
/// http://localhost:52773/zpm-shields/registry/mode?project=appmsw-dbdeploy&color=gold
/// http://localhost:52773/zpm-shields/registry/mode?project=https:%2F%2Fpm.community.intersystems.com%2Fpackages%2Fzapm%2F&color=gold
/// http://localhost:52773/zpm-shields/both/mode?module=sergeymi37%2Fappmsw-dbdeploy&project=appmsw-dbdeploy&color=gold
/// http://iris-test:52773/zpm-shields/both/mode?module=rcemper%2Fzpmshow&project=zpmshow
ClassMethod GetZpmVersion(input = "") As %Status
{
	set vers="0"
	set title=" ZPM repo"
	set color="DDA0DD" ;default Plum
	set i=""
	for { set i=$o(%request.Data(i)) quit:i=""
		set:$o(%request.Data(i,""),-1)'="" Par("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
	}
	if $Data(Par("%request.Data","debug"),debug)

	if %request.URL["/repo/" {	
		if '$Data(Par("%request.Data","module"),module) quit $select('$get(debug):$$$OK,1:$$$ERROR($$$GeneralError,"no parameter module"))
		set st=..GetModule(module,.res)
		if 'st quit:'$get(debug) $$$OK write  quit st
		set title=" Repository: "_$GET(res("zpmname"))
		set vers=$GET(res("ver"))
	}
	elseif %request.URL["/registry/" { 
		if '$Data(Par("%request.Data","project"),project) quit $select('$get(debug):$$$OK,1:$$$ERROR($$$GeneralError,"no parameter project"))
		set st=..GetReg(project,.res)
		if 'st quit:'$get(debug) $$$OK write  quit st
		set title=" Registry: "_$GET(res("zpmname"))
		set vers=$GET(res("ver"))
	}
	elseif %request.URL["/both/" { 
		if '$Data(Par("%request.Data","module"),module) quit $select('$get(debug):$$$OK,1:$$$ERROR($$$GeneralError,"no parameter module"))
		set st=..GetModule(module,.res)
		if 'st quit:'$get(debug) $$$OK write  quit st
		set title=" Repository: "_$GET(res("zpmname"))_" v."_$GET(res("ver"))

		if '$Data(Par("%request.Data","project"),project) quit $select('$get(debug):$$$OK,1:$$$ERROR($$$GeneralError,"no parameter project"))
		set st=..GetReg(project,.res2)
		if 'st quit:'$get(debug) $$$OK write  quit st
		set vers=" Registry: "_$GET(res2("zpmname"))_" v."_$GET(res2("ver"))
	}

	if $Data(Par("%request.Data","color"),color)

	set title=$replace($replace(title," ","%20"),"-","%7e") ;%2d -
	set vers=$replace($replace(vers," ","%20"),"-","%7e")
	;https://img.shields.io/badge/Available%20on-Intersystems%20Open~Exchange-688E23.svg
	;https://shields.io/category/build
	if $D(res("color"),color)
	set uri="https://img.shields.io/badge/"_title_"-"_vers_"-"_color_".svg"

	if $Data(Par("%request.Data","debug"),debug) {
		&html<<h1>Mode: Debug</h1><pre>>
		write input,!,$g(url),!,$g(vers),!,$g(uri),!,$g(color),!
		zw Par zw res zw res2
		zw %request 
		&html<</pre>>
		quit $$$OK
	}	
	set st=##class(dc.appmsw.shields).GetHttp(uri,.out)
	if 'st quit $select('$get(debug):$$$OK,1:st)
	if ..Stream2String($Get(out("content")),.svg) {
		set %response.CharSet = "utf-8"
    	set %response.ContentType = "image/svg+xml"
		write $tr($GET(svg),"~","-")
	}	
	quit $$$OK
	/*	
	set %response.CharSet = "utf-8"
    set %response.ContentType = "image/svg+xml"
	set svg=##class(dc.appmsw.shields).getXData("ShieldsSvg")
	set svg=$replace(svg,"VERSION",vers)
	set svg=$replace(svg,"Available on",title)
	write $replace(svg,"#00b2a9",color)
	return $$$OK
	*/
}

/// set st=##class(dc.appmsw.shields).GetModule("sergeymi37/appmsw-dbdeploy",.result)
ClassMethod GetModule(project As %String, ByRef result) As %Status
{
	if project'="" {
		;(https://raw.githubusercontent.com/SergeyMi37/appmsw-dbdeploy/master/doc/Screenshot_4.png)
		set url=project
		if project'["http" { //default on github
			set url="https://raw.githubusercontent.com/"_project_"/master/module.xml"
		}
		elseif project["github.com" {
			set url="https://raw.githubusercontent.com/"_$p(project,"/",4,5)_"/master/module.xml"
		}
		elseif project["gitlab.com" {  ;global https://gitlab.com/sergeymi/test/-/raw/master/module.xml
			set url=$p(project,"/",1,5)_"/-/raw/master/module.xml"
		}
		elseif project["gitlab" {  ;local http://gitlab.vmk.ru/iris/app/raw/master/module.xml
			set url=$p(project,"/",1,5)_"/raw/master/module.xml"
		}
		
		set result("url")=url
		//write url
		set st=##class(dc.appmsw.shields).GetHttp(url,.out)
		quit:'st st

		if ..Stream2String($Get(out("content")),.module) {
			set module=$zconvert(module,"L")
			set result("ver")=$p($p(module,"<version>",2),"</version>",1)
			set result("zpmname")=$p($p(module,"<name>",2),"</name>",1)
			set result("module")=module
		}

	}
	if $GET(module)'="" quit $$$OK
	set result("color")="red"
	set result("ver")="none"
	set result("zpmname")="undefined"
	quit $$$ERROR($$$GeneralError,"error module "_project)
}

/// s svg=##class(dc.appmsw.shields).GetReg("appmsw-dbdeploy",.result)
ClassMethod GetReg(project As %String, ByRef result) As %String
{
	;https://pm.community.intersystems.com/packages/-/all
	;https://pm.community.intersystems.com/packages/zapm/
	;http://iris-test:52773/registry/packages/csvgen/
	if project'="" {
		if project'["http" { //default on github
			set url="https://pm.community.intersystems.com/packages/"_project_"/"
		}
		else {  ;local http://gitlab.vmk.ru/iris/app/raw/master/module.xml
			set url=project
		}
		set result("url")=url
		//write url
		set st=##class(dc.appmsw.shields).GetHttp(url,.out)
		quit:'st st
		if ..Stream2String($Get(out("content")),.module) {
			set json={}.%FromJSON(module)
			set result("ver")=json.version
			set result("zpmname")=json.name
			set result("module")=module
		}
	}
	if $GET(module)'="" quit $$$OK
	set result("color")="red"
	set result("ver")="none"
	set result("zpmname")="undefined"
	quit $$$ERROR($$$GeneralError,"error module "_project)
}

/// write ##class(dc.appmsw.shields).GetHttp("https://raw.githubusercontent.com/SergeyMi37/zapm/master/module.xml",.out)
ClassMethod GetHttp(aURL = "", aDATA) As %Status
{
	set part1=$p(aURL,"/",3),part2=$p(aURL,"/",4,$l(aURL,"/")),params=$p(aURL,"?",2)
	#; Server
	set server=$p(part1,":",1) quit:(server="") $$$ERROR($$$GeneralError,"0:no server")
	#; Port
	set port=$p(part1,":",2)
	#; Address
	set location=$p(part2,"?",1) quit:(location="") $$$ERROR($$$GeneralError,"0:missing address"_" - "_location)
	#; Create HTTP request to download the file
	set HttpRequest=##class(%Net.HttpRequest).%New()
	set HttpRequest.Server=server
	if $f($zcvt(aURL,"L"),"https://") {
		set:(port="") port=443
		set HttpRequest.Https=1
		;set HttpRequest.FollowRedirect = 1
		set HttpRequest.SSLConfiguration=..CheckSSLCertificate("DefaultSSL")
	
	#; Request HTTP
	} else {
		set:(port="") port=80
	}
	;w !,server,!,location,!,port,!,params
	set HttpRequest.Port=port

	#; Fill in the parameters
	for i=1:1:$l(params,"&") { s pair=$p(params,"&",i),name=$p(pair,"=",1),value=$p(pair,"=",2)
		continue:(name="")	
		;Conversion, to prevent double conversion
		s value=$zcvt(value,"I","URL") 
		d HttpRequest.SetParam(name,value)
	} ; /for i
	
	#; Execute the query
	Try { d HttpRequest.Get(location) } Catch Error { s err=Error.AsSystemError() }
	quit:($g(err)'="") $$$ERROR($$$GeneralError,err)
	#; The processed response is received
	set HttpResponse=HttpRequest.HttpResponse 
	quit:('$isobject(HttpResponse)) $$$ERROR($$$GeneralError,"the server does not return a response")
	quit:(HttpResponse.StatusCode'=200) $$$ERROR($$$GeneralError,HttpResponse.ReasonPhrase)
	s aDATA("status")=HttpResponse.StatusCode
	#; Parse the response from the server, keeping the structure of the aDATA
	set aDATA("contentType")=HttpResponse.ContentType
	#; The name of the file received via the "content-disposition" as "attachment;filename="name.ext";"
	s fileName=HttpResponse.GetHeader("content-disposition")
	s aDATA("content-disposition")=fileName
	if ($l(fileName,"*=utf-8''")>1) {
		s fileName=$p(fileName,"*=utf-8''",2)
		s fileName=##CLASS(%CSP.Page).UnescapeURL(fileName)
		s fileName=$zcvt(fileName,"I","UTF8")
	} else { s fileName=$p(fileName,"filename=",2),fileName=$tr($p(fileName,";",1),"""'","") }
	
	#; If the file name is not specified, use as the name of the piece of the link
	s:(fileName="") fileName=$p(location,"/",$l(location,"/"))
	s aDATA("content")=HttpResponse.Data
	s aDATA("fileName")=$zcvt(fileName,"I","URL")
	quit $$$OK
}

/// Stream convert to string
/// write ##class(dc.appmsw.shields).Stream2String(resp,.str)
ClassMethod Stream2String(resp As %Stream, StringValue As %String) As %Status
{
	set st=$$$OK
	set StringValue=""
	i '$isobject(resp) q $$$ERROR($$$GeneralError,"An empty stream")
	d resp.Rewind() 
	set StringValue=resp.Read($$$MaxStringLength) 
	while '(resp.AtEnd) { 
		s StringValue($i(i))=resp.Read($$$MaxStringLength) 
	}
	q st
}

ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

/// s svg=##class(dc.appmsw.shields).getXData(":ShieldsSvg") write !,svg
ClassMethod getXData(name As %String) As %String
{
	
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set Name = $p(name, ":", *)
		
	if ##class(%Dictionary.QueryDefinition).IDKEYExists(class, Name) {
		set query = ##class(%Dictionary.QueryDefinition).IDKEYOpen(class, Name,,.sc)
		throw:$$$ISERR(sc) ##class(%Exception.StatusException).CreateFromStatus(sc)
		set data = query.SqlQuery
	} elseif ##class(%Dictionary.XDataDefinition).IDKEYExists(class, Name) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,Name,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,Name,$$$cXDATAdata,i))
		}
		set data = stream.Read($$$MaxLocalLength)
	
	} else {
		throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, $$$FormatText("Class %1 does not have a Query or XData element named %2",""), class, Name))
	}
	
	return $GET(data)
}

XData ShieldsSvg
{
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="150" height="20" role="img" aria-label="Available on: VERSION">
<title>Available on: VERSION</title>
<linearGradient id="s" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient>
<clipPath id="r"><rect width="150" height="20" rx="3" fill="#fff"/></clipPath>
<g clip-path="url(#r)"><rect width="77" height="20" fill="#555"/>
<rect x="77" width="173" height="20" fill="#00b2a9"/>
<rect width="150" height="20" fill="url(#s)"/>
</g>
<g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="110">
<text aria-hidden="true" x="395" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="670">Available on</text>
<text x="395" y="140" transform="scale(.1)" fill="#fff" textLength="670">Available on</text>
<text aria-hidden="true" x="1125" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="430">VERSION</text>
<text x="1125" y="140" transform="scale(.1)" fill="#fff" textLength="430">VERSION</text>
</g>
</svg>
}

}

