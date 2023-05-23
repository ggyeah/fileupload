<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "java.io.*" %>
<%	
	//upload 폴더 위치값 받아오기
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir);

	//요청값
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	//디버깅
	System.out.println(boardNo);
	System.out.println(boardFileNo);
	
	//db연결
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");

	// 1) upload 폴더에서 파일 삭제 ---------------------------
	String selectSql = "SELECT save_filename FROM board_file WHERE board_no = ? and board_file_no = ?";
	PreparedStatement selectStmt = conn.prepareStatement(selectSql);
	selectStmt.setInt(1, boardNo);
	selectStmt.setInt(2, boardFileNo);
	ResultSet selectRs = selectStmt.executeQuery();
	
	//파일이름을 찾아서 파일삭제
	String saveFilename = "";
	if(selectRs.next()) {
		saveFilename = selectRs.getString("save_filename");
	}
	File f = new File(dir+"/"+saveFilename);
	if(f.exists()) {
		f.delete();
		System.out.println(saveFilename + "파일삭제");
	}

	//2) db에서 파일삭제 --------------------------------
	String sql = "Delete from board WHERE board_no = ?"; 
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	
	int row = stmt.executeUpdate();
	
	if(row == 0) { 
		System.out.println(row + " <- 삭제실패"); 
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
		} else {
		      response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		      System.out.println(row + " <- 삭제성공");
		}
	
%>