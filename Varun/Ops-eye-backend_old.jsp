<%@ page import="com.newgen.wfdesktop.util.*, com.newgen.wfdesktop.session.*,com.newgen.wfdesktop.exception.*,Jdts.DataObject.JPDBString,java.io.*,java.util.*" %>


<%@ page import="com.newgen.wfdesktop.xmlapi.*" %>
<%@ page import="com.newgen.omni.jts.txn.*,com.newgen.omni.wf.util.app.*,com.newgen.omni.wf.util.excp.*"%>
<%@ page import="com.newgen.wfdesktop.xmlapi.WFXmlResponse" %>
<%@ page import="com.newgen.wfdesktop.xmlapi.WFCallBroker" %>

<jsp:useBean id="wfsession" class="com.newgen.wfdesktop.session.WFSession" scope="session"/>

<%
	
	



%>

<%
	
	try{
    	
		// WriteLog("Inside Ops-eye JSP.");
		
		String params = request.getParameter("params");		
		
		String sJtsIp = wfsession.getJtsIp();
		int iJtsPort = wfsession.getJtsPort();
		String sCabName = wfsession.getEngineName();	
		String sSessionId = wfsession.getSessionId();
		
		String reqType = params.split("~")[0];
		if("dashboardContent".equals(reqType)){
			// Query logic starts
			
			String op = "", query = "", strArray[], inputXML = "", sOutputXml = "", parseString = "";
			
			
			// Part-I
			
			// Query-1
			query = "SELECT COUNT(*) as UserCount FROM PDBConnection WITH (NOLOCK)";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					String UserCount = parsergetlist.getVal("UserCount");
					
					op += "STAT | 1 | Concurrent Users (Now) | "+ UserCount +" | 55% up | trend ~ ";
					
				}
			}
			
			
			// Query for Top Created Processes by Ext
			query = "SELECT top 2 processname, count(*) AS ProcessCount FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname IN ('mqserviceuser') GROUP BY processname ORDER BY ProcessCount DESC";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			String topCreatedProcessesExt = "";
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					topCreatedProcessesExt += parsergetlist.getVal("processname") + ", ";
				}
			}
			
			if(topCreatedProcessesExt.length() > 2)
				topCreatedProcessesExt = topCreatedProcessesExt.substring(0, topCreatedProcessesExt.length()-2);
			
			// Query for Top Created Processes by User
			query = "SELECT top 2 processname, count(*) AS ProcessCount FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname NOT IN ('mqserviceuser') GROUP BY processname ORDER BY ProcessCount DESC";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			String topCreatedProcessesUser = "";
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					topCreatedProcessesUser += parsergetlist.getVal("processname") + ", ";
				}
			}
			
			if(topCreatedProcessesUser.length() > 2)
				topCreatedProcessesUser = topCreatedProcessesUser.substring(0, topCreatedProcessesUser.length()-2);
			
			// Query-2
			query = "SELECT COUNT(*) AS WICountExt FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname IN ('mqserviceuser')";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					String WICountExt = parsergetlist.getVal("WICountExt");
					if("0".equals(WICountExt)) topCreatedProcessesExt = "NA";
					
					op += "STAT | 2 | WI Created Last 1 Hour (Ext) | "+ WICountExt +" | Top: "+topCreatedProcessesExt+" | info ~ ";
					
				}
			}
			
			
			// Query-3
			query = "SELECT COUNT(*) AS WICountUser FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname NOT IN ('mqserviceuser')";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					String WICountUser = parsergetlist.getVal("WICountUser");
					if("0".equals(WICountUser)) topCreatedProcessesUser = "NA";
					
					op += "STAT | 3 | WI Created Last 1 Hour (Users) | "+ WICountUser +" | Top: "+topCreatedProcessesUser+" | info ~ ";
					
				}
			}
		
			
			// Query for Top Processes in Error handling Queue
			query = "SELECT TOP 2 processname, COUNT(*) AS ErrorWICount FROM QUEUEVIEW WITH (NOLOCK) WHERE queuename IN (SELECT QueueName FROM QUEUEDEFTABLE WITH (NOLOCK) WHERE QueueName LIKE '%ERROR%') GROUP BY processname ORDER BY ErrorWICount DESC";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			String topErrorProcesses = "";
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					topErrorProcesses += parsergetlist.getVal("processname") + ", ";
				}
			}
			
			if(topErrorProcesses.length() > 2)
				topErrorProcesses = topErrorProcesses.substring(0, topErrorProcesses.length()-2);
			
			// Query-4
			query = "SELECT COUNT(*) AS ErrorWICount FROM QUEUEVIEW WITH (NOLOCK) WHERE queuename IN (SELECT QueueName FROM QUEUEDEFTABLE WITH (NOLOCK) WHERE QueueName LIKE '%ERROR%')";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");	
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					// JSON logic starts

					String ErrorWICount = parsergetlist.getVal("ErrorWICount");
					
					op += "STAT | 4 | Error Handling Queue (Now) | "+ ErrorWICount +" | Top: "+topErrorProcesses+" | alert ~ ";
					
				}
			}
			
			
			// Query-6
			
			query = "SELECT q.ProcessName, q.QueueName, COALESCE(COUNT(w.QueueName), 0) AS QueueWIsCount, (SELECT MIN(v.IntroductionDateTime) FROM QUEUEVIEW v WHERE v.QueueName = q.QueueName AND v.IntroductionDateTime IS NOT NULL) AS OldestIntro FROM QUEUEDEFTABLE q WITH (NOLOCK) INNER JOIN PROCESSDEFTABLE p ON p.ProcessName = q.ProcessName LEFT JOIN WFINSTRUMENTTABLE w ON w.QueueName = q.QueueName where q.QUEUENAME NOT LIKE '%Query%' AND q.QUEUENAME NOT LIKE '%Swimlane%' GROUP BY q.ProcessName, q.QueueName ORDER BY q.ProcessName, q.QueueName";
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");
			
			
			Map<String,List<String>> processMap = new TreeMap<String,List<String>>();	
			Map<String,String> QueueWIsDataMap = new HashMap<String,String>(); // get the WI count per Queue and oldest WI introduced
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					String processName = parsergetlist.getVal("ProcessName");
					
					String QueueName = parsergetlist.getVal("QueueName");
					
					if(!processMap.containsKey(processName)) processMap.put(processName, new ArrayList<String>());
					
					processMap.get(processName).add(QueueName);
					
					String QueueWIsCount = parsergetlist.getVal("QueueWIsCount");
					String OldestIntro = parsergetlist.getVal("OldestIntro");
					
					QueueWIsDataMap.put(QueueName, QueueWIsCount + "~" + OldestIntro);
				}
			}
			
			int i = 0;
			for(String processName : processMap.keySet()){
				
				String PendingWICount = "", ErrorWICount = "";
				
				// Query for Pending WIs per Process
				query = "SELECT COUNT(*) AS PendingWICount FROM QUEUEVIEW WITH (NOLOCK) WHERE queuename IN (SELECT QueueName FROM QUEUEDEFTABLE WITH (NOLOCK) WHERE QueueName NOT LIKE '%Introduction%' AND QueueName NOT LIKE '%Initiation%' AND QueueName NOT LIKE '%Exit%' AND QueueName NOT LIKE '%Discard%') AND PROCESSNAME = '"+ processName +"'";
				
				inputXML = "<?xml version=\"1.0\"?>"+
				"<APSelectWithColumnNames_Input>"+ 
				"<Option>APSelectWithColumnNames</Option>"+
				"<EngineName>" + sCabName + "</EngineName> "+
				"<SessionId>" + sSessionId + "</SessionId>"+
				"<Query>" + query + "</Query>"+
				"</APSelectWithColumnNames_Input>";		
				
				sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
				
				parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
				
				strArray = parseString.split("</Record>");
				
				for (String record : strArray) {
					if (!record.trim().isEmpty()) {
						WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
				
						PendingWICount = parsergetlist.getVal("PendingWICount");		
					}
				}
				
				
				// Query for Error WIs per Process
				query = "SELECT COUNT(*) AS ErrorWICount FROM QUEUEVIEW WITH (NOLOCK) WHERE queuename IN (SELECT QueueName FROM QUEUEDEFTABLE WITH (NOLOCK) WHERE QueueName LIKE '%ERROR%' AND QueueName NOT LIKE '%Introduction%' AND QueueName NOT LIKE '%Initiation%' AND QueueName NOT LIKE '%Exit%' AND QueueName NOT LIKE '%Discard%') AND PROCESSNAME = '"+ processName +"'";
				
				inputXML = "<?xml version=\"1.0\"?>"+
				"<APSelectWithColumnNames_Input>"+ 
				"<Option>APSelectWithColumnNames</Option>"+
				"<EngineName>" + sCabName + "</EngineName> "+
				"<SessionId>" + sSessionId + "</SessionId>"+
				"<Query>" + query + "</Query>"+
				"</APSelectWithColumnNames_Input>";		
				
				sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
				
				parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
				
				strArray = parseString.split("</Record>");
				
				for (String record : strArray) {
					if (!record.trim().isEmpty()) {
						WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
				
						ErrorWICount = parsergetlist.getVal("ErrorWICount");
					}
				}
				
				
				String processId = "p" + i;	

				// 'PROCESS | p1 | Credit Card Onboarding | 120 | 14 | false'
				// 'ACTIVITY | Now | 10 | 5 ~ ACTIVITY | -10m | 15 | 8'
				
				op += "PROCESS | " + processId +" | "+ processName +" | "+ PendingWICount +" | "+ ErrorWICount +" | false ~ ";
				i++;
			}
			
			
			// Activity Trends part starts
			
			String Last10MinExt = "", Last20MinExt = "", Last30MinExt = "", Last40MinExt = "", Last50MinExt = "", Last60MinExt = "";
			String Last10MinUser = "", Last20MinUser = "", Last30MinUser = "", Last40MinUser = "", Last50MinUser = "", Last60MinUser = "";
			op += "ACTIVITY | Now | 0 | 0 ~ ";
			
			// for Ext
			query = "SELECT SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -10, GETDATE()) THEN 1 ELSE 0 END) AS Last10Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -20, GETDATE()) THEN 1 ELSE 0 END) AS Last20Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -30, GETDATE()) THEN 1 ELSE 0 END) AS Last30Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -40, GETDATE()) THEN 1 ELSE 0 END) AS Last40Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -50, GETDATE()) THEN 1 ELSE 0 END) AS Last50Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -60, GETDATE()) THEN 1 ELSE 0 END) AS Last60Min FROM QUEUEVIEW WITH (NOLOCK) WHERE createdbyname IN ('mqserviceuser');"; 
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					Last10MinExt = parsergetlist.getVal("Last10Min");
					Last20MinExt = parsergetlist.getVal("Last20Min");
					Last30MinExt = parsergetlist.getVal("Last30Min");
					Last40MinExt = parsergetlist.getVal("Last40Min");
					Last50MinExt = parsergetlist.getVal("Last50Min");
					Last60MinExt = parsergetlist.getVal("Last60Min");
					
					// 'ACTIVITY | Now | 10 | 5 ~ ACTIVITY | -10m | 15 | 8 ~ ACTIVITY | -20m | 20 | 12 ~ ACTIVITY | -30m | 12 | 6 ~ ACTIVITY | -40m | 25 | 15 ~ ACTIVITY | -50m | 18 | 9 ~ ACTIVITY | -60m | 8 | 4'
					
					
				}
			}
			
			// for Users
			query = "SELECT SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -10, GETDATE()) THEN 1 ELSE 0 END) AS Last10Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -20, GETDATE()) THEN 1 ELSE 0 END) AS Last20Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -30, GETDATE()) THEN 1 ELSE 0 END) AS Last30Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -40, GETDATE()) THEN 1 ELSE 0 END) AS Last40Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -50, GETDATE()) THEN 1 ELSE 0 END) AS Last50Min, SUM(CASE WHEN CreatedDatetime >= DATEADD(MINUTE, -60, GETDATE()) THEN 1 ELSE 0 END) AS Last60Min FROM QUEUEVIEW WITH (NOLOCK) WHERE createdbyname NOT IN ('mqserviceuser');"; 
			
			inputXML = "<?xml version=\"1.0\"?>"+
			"<APSelectWithColumnNames_Input>"+ 
			"<Option>APSelectWithColumnNames</Option>"+
			"<EngineName>" + sCabName + "</EngineName> "+
			"<SessionId>" + sSessionId + "</SessionId>"+
			"<Query>" + query + "</Query>"+
			"</APSelectWithColumnNames_Input>";		
			
			sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
			
			parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
			
			strArray = parseString.split("</Record>");
			
			for (String record : strArray) {
				if (!record.trim().isEmpty()) {
					WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
			
					Last10MinUser = parsergetlist.getVal("Last10Min");
					Last20MinUser = parsergetlist.getVal("Last20Min");
					Last30MinUser = parsergetlist.getVal("Last30Min");
					Last40MinUser = parsergetlist.getVal("Last40Min");
					Last50MinUser = parsergetlist.getVal("Last50Min");
					Last60MinUser = parsergetlist.getVal("Last60Min");
					
					// 'ACTIVITY | Now | 10 | 5 ~ ACTIVITY | -10m | 15 | 8 ~ ACTIVITY | -20m | 20 | 12 ~ ACTIVITY | -30m | 12 | 6 ~ ACTIVITY | -40m | 25 | 15 ~ ACTIVITY | -50m | 18 | 9 ~ ACTIVITY | -60m | 8 | 4'
					
					
				}
			}
			
			op += "ACTIVITY | -10m | "+Last10MinExt+" | "+Last10MinUser+" ~ ACTIVITY | -20m | "+Last20MinExt+" | "+Last20MinUser+" ~ ACTIVITY | -30m | "+Last30MinExt+" | "+Last30MinUser+" ~ ACTIVITY | -40m | "+Last40MinExt+" | "+Last40MinUser+" ~ ACTIVITY | -50m | "+Last50MinExt+" | "+Last50MinUser+" ~ ACTIVITY | -60m | "+Last60MinExt+" | "+Last60MinUser;
			
			op += " ]-[ ";
			
			
			// Part-II
			String temp = "";
			
			StringBuilder part2 = new StringBuilder("");
			i = 0;
			for(String processName : processMap.keySet()){
				
				String processId = "p" + i;	

				List<String> list = processMap.get(processName);
				
				for(String QueueName : list){
					String WICount_Oldest[] = QueueWIsDataMap.get(QueueName).split("~");
					
					String QueueWIsCount = WICount_Oldest.length > 0 ? WICount_Oldest[0] : "0";
					String QueueWIsOldest = WICount_Oldest.length > 1 ? WICount_Oldest[1] : "NA";
					// temp += QueueWIsDataMap.get(QueueName) + " :: ";
					part2.append(processId +" | "+ processName +" | "+ QueueName +" | "+ QueueWIsCount +" | "+ QueueWIsOldest +" | up | 5 | 2h 45m ~ ");
				}
				
				// "p1 | Credit Card Onboarding | Application Review | 45 | 1h 30m | up | 5 | 2h 45m"
				i++;
			}
			op += part2.toString();
			
			out.println(op);
		
		} else{
			
			String op = "", query = "", strArray[], inputXML = "", sOutputXml = "", parseString = "";
			String processName = params.split("~")[1];
			String source = params.split("~")[2];
			
			if("PROCESS_SELECTOR_ERRORS".equals(source)){
			
				// Query-1
				
				query = "SELECT processinstanceid AS WINAME, activityname AS WSName, entryDATETIME FROM QUEUEVIEW WITH (NOLOCK) WHERE queuename IN (SELECT QueueName FROM QUEUEDEFTABLE WITH (NOLOCK) WHERE QueueName LIKE '%ERROR%') AND PROCESSNAME = '"+ processName +"'";
			
				
				inputXML = "<?xml version=\"1.0\"?>"+
				"<APSelectWithColumnNames_Input>"+ 
				"<Option>APSelectWithColumnNames</Option>"+
				"<EngineName>" + sCabName + "</EngineName> "+
				"<SessionId>" + sSessionId + "</SessionId>"+
				"<Query>" + query + "</Query>"+
				"</APSelectWithColumnNames_Input>";		
				
				sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
				
				parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
				
				strArray = parseString.split("</Record>");	
				
				for (String record : strArray) {
					if (!record.trim().isEmpty()) {
						WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
				
						// JSON logic starts

						String WINAME = parsergetlist.getVal("WINAME");
						String WSName = parsergetlist.getVal("WSName");
						
						op += "ERRORWI|123|"+ WINAME +"|"+ WSName +"~";
						
					}
				}
				
			
			} else if("SELECTED_PROCESS_PENDING".equals(source)){
				
				op += "ERRORWI|123|"+ "WINAME1" +"|"+ "AF_Card_CRU" +"~";
				
			} else if("TOP_STAT_LAST_HOUR_EXT".equals(source)){
				
				query = "SELECT processinstanceid AS WINAME, queuename AS WSName FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname IN ('mqserviceuser') ORDER BY processinstanceid";
			
				
				inputXML = "<?xml version=\"1.0\"?>"+
				"<APSelectWithColumnNames_Input>"+ 
				"<Option>APSelectWithColumnNames</Option>"+
				"<EngineName>" + sCabName + "</EngineName> "+
				"<SessionId>" + sSessionId + "</SessionId>"+
				"<Query>" + query + "</Query>"+
				"</APSelectWithColumnNames_Input>";		
				
				sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
				
				parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
				
				strArray = parseString.split("</Record>");	
				
				for (String record : strArray) {
					if (!record.trim().isEmpty()) {
						WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
				
						// JSON logic starts

						String WINAME = parsergetlist.getVal("WINAME");
						String WSName = parsergetlist.getVal("WSName");
						
						op += "ERRORWI|123|"+ WINAME +"|"+ WSName +"~";
					}
				}
				
			} else if("TOP_STAT_LAST_HOUR_USERS".equals(source)){
				
				query = "SELECT processinstanceid AS WINAME, queuename AS WSName FROM QUEUEVIEW WITH (NOLOCK) WHERE CreatedDatetime >= DATEADD(HOUR, -1, GETDATE()) AND createdbyname NOT IN ('mqserviceuser') ORDER BY processinstanceid";
			
				
				inputXML = "<?xml version=\"1.0\"?>"+
				"<APSelectWithColumnNames_Input>"+ 
				"<Option>APSelectWithColumnNames</Option>"+
				"<EngineName>" + sCabName + "</EngineName> "+
				"<SessionId>" + sSessionId + "</SessionId>"+
				"<Query>" + query + "</Query>"+
				"</APSelectWithColumnNames_Input>";		
				
				sOutputXml = WFCallBroker.execute(inputXML,sJtsIp,iJtsPort,1);
				
				parseString = sOutputXml.substring(sOutputXml.indexOf("<Records>")+"<Records>".length(),sOutputXml.indexOf("</Records>"));
				
				strArray = parseString.split("</Record>");	
				
				for (String record : strArray) {
					if (!record.trim().isEmpty()) {
						WFXmlResponse parsergetlist = new WFXmlResponse(record + "</Record>");
				
						// JSON logic starts

						String WINAME = parsergetlist.getVal("WINAME");
						String WSName = parsergetlist.getVal("WSName");
						
						op += "ERRORWI|123|"+ WINAME +"|"+ WSName +"~";
					}
				}
				
			}
			
			out.println(op);
		}
	}
	catch(Exception e){    		
		// WriteLog("Exception occured::" + e);
		out.println("Exception occured::" + e);
	}

%>