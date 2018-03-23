var fso = new ActiveXObject("Scripting.FileSystemObject");
        
function sleep(ms) {
ms += new Date().getTime();
while (new Date() < ms){}
} 

function wtiteToResultFile(file_name, file_data) {
	f = fso.CreateTextFile(file_name, true);
	f.Write(file_data);
	f.Close();
}



function Run()
{
arg=WScript.Arguments;

            var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
           
            var sr = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v="http://www.omkit.ru/tfs/omniintegration/v1"><soapenv:Header/><soapenv:Body><v:GetLinksToWIOneS><v:RfcId>'
+arg(0)+ 
'</v:RfcId></v:GetLinksToWIOneS></soapenv:Body></soapenv:Envelope>';

            // Send the POST request
 
            //xmlhttp.withCredentials = true;

            xmlhttp.open('POST', 'http://vsys00658.d0.vsw.ru/OMKIT.Tfs.Integration/TfsIntegrationService.svc', false);
            xmlhttp.setRequestHeader('Content-Type', 'text/xml; charset=utf-8');
xmlhttp.setRequestHeader('SOAPAction', 'http://www.omkit.ru/tfs/omniintegration/v1/ITfsIntegrationService/GetLinksToWIOneS');
            xmlhttp.send(sr);
      
  
     if(xmlhttp.status == 200) {
       elements = xmlhttp.responseXML.getElementsByTagName('GetLinksToWIOneSResult');

wtiteToResultFile("tmp/result.tmp",elements[0].text);
         }
  }



Run();