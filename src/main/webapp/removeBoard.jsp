<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
//요청값
int boardNo = Integer.parseInt(request.getParameter("boardNo"));
int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
//디버깅
System.out.println(boardNo);
System.out.println(boardFileNo);
//db연결
Class.forName("org.mariadb.jdbc.Driver");
Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");

//삭제하기전 삭제할 정보 확인하는 쿼리
String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
PreparedStatement stmt = conn.prepareStatement(sql);
ResultSet rs = stmt.executeQuery();

HashMap<String, Object> map = null;
if(rs.next()) {
	map = new HashMap<>();
	map.put("boardTitle", rs.getString("boardTitle")); 
	map.put("originFilename", rs.getString("originFilename"));
}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>removeBoard</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp?boardNo=<%=boardNo%>&boardFileNo=<%=boardFileNo%>" method="post">
	<table>
		<tr>
			<th>boardTitle</th>
			<td>
				<%=map.get("boardTitle")%>
			</td>
		</tr>
		<tr>
			<th>boardFile</th>
			<td>
				<%=map.get("originFilename")%>
			</td>
		</tr>
		<tr>
		<tr><td> 삭제하시겠습니까? </td>
	         <td colspan="2">
	              <button type="submit" class="btn btn-danger">삭제</button>
			</td>
		</tr>
		
	</table>
	</form>
</body>
</html>