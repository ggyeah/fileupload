<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	/*
	SELECT 
		b.board_title boardTitle,
		f.origin_filename originFilename,
		f.save_filename saveFilename,
		path
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no
	ORDER BY b.createdate DESC
	*/
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");

	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();

	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
	HashMap<String, Object> m = new HashMap<>();
	m.put("boardNo", rs.getInt("boardNo")); 
	m.put("boardTitle", rs.getString("boardTitle")); 
	m.put("boardFileNo", rs.getInt("boardFileNo")); 
	m.put("originFilename", rs.getString("originFilename"));
	m.put("saveFilename", rs.getString("saveFilename"));
	m.put("path", rs.getString("path"));
	list.add(m);
}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	 <div>
     <%
         if(session.getAttribute("loginMemberId") == null) { // 로그인전이면 로그인폼출력
     %>
        <form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
          <table>
             <tr>
                <td>아이디</td>
                <td><input type="text" name="memberId"></td>
             </tr>
             <tr>
                <td>패스워드</td>
                <td><input type="password" name="memberPw"></td>
             </tr>
          </table>
           <button type="submit">로그인</button>
        </form>
      <%   
         }else{
        	 String loginMemberId = (String)session.getAttribute("loginMemberId");
      %>
     <h2>&#9989;<%=loginMemberId%>접속중</h2> 
     <div><a href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a></div>
      <%   
         }
      %>
      </div>
			      
	<h1>PDF 자료 목록</h1>
	<%
	 if(session.getAttribute("loginMemberId") != null) { // 로그인 상태여야만 자료추가가 보임
	 %>
	<a href="<%=request.getContextPath()%>/addBoard.jsp">자료추가</a>
	 <%
      	}
  	 %>
	<table>
		<tr>
			<td>boardTitle</td>
			<td>originFilename</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(String)m.get("boardTitle")%></td>
					<td>
						<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
							<%=(String)m.get("originFilename")%></a>
					</td>
				<%
				 if(session.getAttribute("loginMemberId") != null) { // 로그인 상태여야만 수정,삭제가 보임
				 %>
					<td>
						<a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a>
					</td>
					<td>
						<a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a>
					</td>
				 <%
			      	}
			  	 %>
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>