<%@page import="javax.print.attribute.standard.PresentationDirection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir);
	
	int max = 10 * 1024 * 1024; // 1024byte -> 1kbyte, 1024kbyte -> 1mbyte
	
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	//request 객체를 MultipartRequest는의 API를 사용할 수 있도록 랩핑
	//DefaultFileRenamePolicy: 업로드 폴더내 동일한 이름이 있으면 뒤에 숫자를 추가 
	
	//MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다
	
	//업로드 파일이 PDF파일이 아니면
	if(mRequest.getContentType("boardFile").equals("application/pdf")==false) {
		//이미 저장된 파일을 삭제
		System.out.println("PDF파일이 아닙니다"); 
		String saveFilename = mRequest.getFilesystemName("boardFile");
		File f = new File(dir+"/"+saveFilename); //주소값과 합치면서 \하나가 빠져있어 추가해주어야함 (\\두개가 \하나를 의미함)
		if(f.exists()) {
			f.delete();
			System.out.println(dir+"/"+saveFilename+"파일삭제");
		}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp");
		return;
	}
		
	// 1) input type="text" 값 반환 API
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	//디버깅
	System.out.println(boardTitle + "<--boardTitle"); 
	System.out.println(memberId + "<--memberId"); 
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	/* 2) input type="file" 값(파일 메타 정보) 반환 API (원본파일이름, 저장된파일이름, 컨텐츠타입) --> board_file 테이블 저장
		  <-- 파일(바이너리)은 이미 MultipartRequest객체생성시 (request랩핑시, 9라인)먼저 저장 */
	String type = mRequest.getContentType("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	
	BoardFile boardFile = new BoardFile();
	//boardFile
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	//디버깅
	System.out.println(type + "<--type"); 
	System.out.println(originFilename + "<--originFilename"); 
	System.out.println(saveFilename + "<--saveFilename"); 

/*
	INSERT INTO board(board_title, member_id, updatedate, createdate) 
	VALUES(?, ?, NOW(), NOW())

	INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
	VALUES(?, ?, ?, ?, ?, NOW())

	INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
	String sql = "INSERT 쿼리문";
	pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
	int row = pstmt.executeUpdate(); // insert 쿼리 실행
	ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select쿼리를 진행
	int keyValue = 0;
	if(keyRs.next()){
		keyValue = rs.getInt(1);
	}
*/
	// db연결
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
//--------------------------------------------
	String boardSql = "INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES(?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	boardStmt.executeUpdate();// board 입력 후 키값저장

	ResultSet keyRs = boardStmt.getGeneratedKeys(); // 저장된 키값을 반환
	int boardNo = 0;
	if(keyRs.next()) {
		boardNo = keyRs.getInt(1);
	}
//-----------------------------------------	
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	fileStmt.executeUpdate(); // board_file 입력
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
%>