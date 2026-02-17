<%@ page import="com.newgen.wfdesktop.util.*, com.newgen.wfdesktop.session.*,com.newgen.wfdesktop.exception.*,Jdts.DataObject.JPDBString,java.io.*" %>
<%@ page import="com.newgen.wfdesktop.xmlapi.*" %>
<%@ page import="com.newgen.omni.jts.txn.*,com.newgen.omni.wf.util.app.*,com.newgen.omni.wf.util.excp.*"%>
<%@ page import="com.newgen.wfdesktop.xmlapi.WFXmlResponse" %>
<%@ page import="com.newgen.wfdesktop.xmlapi.WFCallBroker" %>

<jsp:useBean id="wfsession" class="com.newgen.wfdesktop.session.WFSession" scope="session"/>


<%
	
	try{
    	
		// WriteLog("Inside Ops-eye JSP.");
		
		String params = request.getParameter("params");
		// String process = params.split("~")[0];
		// String URN = params.split("~")[1];
		
		
		String sJtsIp = wfsession.getJtsIp();
		int iJtsPort = wfsession.getJtsPort();
		String sCabName = wfsession.getEngineName();	
		String sSessionId = wfsession.getSessionId();
		
		
		// Query logic starts
		
		String op = "demoOP::", query = "", strArray[];
		
		query = "SELECT ProcessName FROM PROCESSDEFTABLE WHERE ProcessState = 'Enabled'";
		
		
		String inputXML = "<?xml version=\"1.0\"?>"+
		"<APSelectWithColumnNames_Input>"+ 
		"<Option>APSelectWithColumnNames</Option>"+
		"<EngineName>" + sCabName + "</EngineName> "+
		"<SessionId>" + sSessionId + "</SessionId>"+
		"<Query>" + query + "</Query>"+
		"</APSelectWithColumnNames_Input>";		
		// WriteLog("inputXML::" + inputXML);
		
		
		String sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);		
		// WriteLog("sOutputXml::" + sOutputXml);
		
		String parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));

		// op = "parseString::" + parseString;
		
		strArray1 = parseString.split("</Record>");	
		
		// WriteLog("strArray::" + strArray);
		
		for (String record : strArray) {
			if (!record.trim().isEmpty()) {
				WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
		
				String ProcessName = parsergetlist.getVal("ProcessName");			
				
				op += ProcessName;
				
				
				
				
			}
		}
		
		
		out.println("In the Ops-eye JSP now with output as --> " + op);
	
	}
	catch(Exception e){    		
		// WriteLog("Exception occured::" + e);
		out.println("Exception occured::" + e);
	}

%>