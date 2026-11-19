package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

/**
 * 행사 포스터 업로드 도우미.
 *
 * 업로드 흐름:
 * 1) cos 의 MultipartRequest 가 파일을 웹 폴더 밖의 임시 폴더(getTempDir)에 먼저 저장한다.
 *    이때 사용자가 올린 원래 파일 이름(예: hack.jsp, 한글·특수문자 이름)은 쓰지 않고
 *    newTempName() 으로 만든 이름으로 저장한다 (processEvent.jsp 의 FileRenamePolicy).
 * 2) 파일 앞부분(매직 넘버)을 읽어 진짜 이미지인지 확인한다. 확장자만 바꾼 파일은 걸러진다.
 * 3) 통과하면 "upload_날짜_임의값.확장자" 로 이름을 새로 지어 resources/images 로 옮긴다.
 */
public class PosterUtil {

	/** 포스터 한 장의 최대 크기 (5MB) */
	public static final long MAX_FILE_SIZE = 5L * 1024 * 1024;

	/** cos 에 넘기는 요청 전체 크기 제한. 5MB 를 조금 넘는 파일도 일단 받아서 친절한 오류를 보여 주려고 넉넉히 잡는다 */
	public static final int MAX_REQUEST_SIZE = 20 * 1024 * 1024;

	/** 업로드된 포스터 파일 이름 규칙. 이 규칙에 맞는 파일만 지운다 (시드 이미지는 지우지 않는다) */
	private static final String UPLOADED_NAME = "^upload_[0-9]{14}_[0-9a-f]{8}\\.(jpg|png|gif|webp)$";

	/** 업로드 임시 폴더 (웹 폴더 밖) */
	public static String getTempDir() throws IOException {
		File dir = new File(System.getProperty("java.io.tmpdir"), "clubcheck-upload");
		if (!dir.isDirectory() && !dir.mkdirs()) {
			throw new IOException("업로드 임시 폴더를 만들 수 없습니다: " + dir);
		}
		return dir.getAbsolutePath();
	}

	/** 업로드 중인 파일의 임시 이름. 원래 파일 이름과 상관없이 영문·숫자로만 만든다 */
	public static String newTempName() {
		return "tmp_" + UUID.randomUUID().toString().replace("-", "") + ".part";
	}

	/** 폴더가 없으면 만든다 (결석사유서 증빙 폴더 WEB-INF/evidence 처럼 처음에는 없을 수 있는 폴더). */
	public static void ensureDir(String dir) throws IOException {
		File folder = new File(dir);
		if (!folder.isDirectory() && !folder.mkdirs()) {
			throw new IOException("폴더를 만들 수 없습니다: " + dir);
		}
	}

	/** 파일 앞부분을 보고 이미지 종류(jpg, png, gif, webp)를 알아낸다. 이미지가 아니면 null. */
	public static String detectImageType(File file) throws IOException {
		byte[] h = new byte[12];
		int n;
		try (InputStream in = new FileInputStream(file)) {
			n = in.readNBytes(h, 0, h.length);
		}
		if (n >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF) {
			return "jpg";
		}
		if (n >= 8 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G'
				&& h[4] == 0x0D && h[5] == 0x0A && h[6] == 0x1A && h[7] == 0x0A) {
			return "png";
		}
		if (n >= 6 && h[0] == 'G' && h[1] == 'I' && h[2] == 'F' && h[3] == '8'
				&& (h[4] == '7' || h[4] == '9') && h[5] == 'a') {
			return "gif";
		}
		if (n >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
				&& h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
			return "webp";
		}
		return null;
	}

	/** 검사를 통과한 임시 파일을 새 이름으로 포스터 폴더에 옮기고, 새 파일 이름을 돌려준다. */
	public static String store(File tempFile, String imageType, String posterDir) throws IOException {
		String stamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		String random = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
		String filename = "upload_" + stamp + "_" + random + "." + imageType;
		Files.move(tempFile.toPath(), new File(posterDir, filename).toPath(), StandardCopyOption.REPLACE_EXISTING);
		return filename;
	}

	/** 업로드로 생긴 포스터라면 지운다. 시드 이미지나 이상한 이름(../ 등)은 건드리지 않는다. */
	public static void deleteUploaded(String posterDir, String filename) {
		if (posterDir != null && filename != null && filename.matches(UPLOADED_NAME)) {
			new File(posterDir, filename).delete();
		}
	}

	/** 임시 파일 정리 (null 이어도 된다) */
	public static void deleteQuietly(File file) {
		if (file != null) {
			file.delete();
		}
	}
}
