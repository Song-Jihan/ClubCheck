package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import dto.Event;
import util.DBConnection;

public class EventDAO {

	// 행사 정보와 함께 현재 신청 인원(applied_count)을 같이 조회한다
	private static final String SELECT_EVENT = "SELECT e.event_id, e.title, e.description, e.event_date, "
			+ "e.location, e.capacity, e.poster_filename, "
			+ "(SELECT COUNT(*) FROM attendance a WHERE a.event_id = e.event_id) AS applied_count "
			+ "FROM club_event e ";

	/** 아직 시작하지 않은 행사를 가까운 날짜순으로 조회한다. */
	public ArrayList<Event> getUpcomingEvents() throws SQLException {
		return selectList(SELECT_EVENT + "WHERE e.event_date >= NOW() ORDER BY e.event_date ASC");
	}

	/** 이미 지난 행사를 최근 날짜순으로 조회한다. */
	public ArrayList<Event> getPastEvents() throws SQLException {
		return selectList(SELECT_EVENT + "WHERE e.event_date < NOW() ORDER BY e.event_date DESC");
	}

	/** 행사 번호로 한 건을 조회한다. 없으면 null 을 돌려준다. */
	public Event getEventById(int eventId) throws SQLException {
		String sql = SELECT_EVENT + "WHERE e.event_id = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return toEvent(rs);
				}
				return null;
			}
		}
	}

	/** 새 행사를 저장하고, DB 가 만들어 준 행사 번호를 돌려준다. */
	public int insert(Event event) throws SQLException {
		String sql = "INSERT INTO club_event (title, description, event_date, location, capacity, poster_filename) "
				+ "VALUES (?, ?, ?, ?, ?, ?)";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			setFields(pstmt, event);
			pstmt.executeUpdate();
			try (ResultSet keys = pstmt.getGeneratedKeys()) {
				if (keys.next()) {
					return keys.getInt(1);
				}
			}
			throw new SQLException("새 행사 번호를 받지 못했습니다.");
		}
	}

	/** 행사 정보를 수정한다. 수정된 행이 있으면 true. */
	public boolean update(Event event) throws SQLException {
		String sql = "UPDATE club_event SET title = ?, description = ?, event_date = ?, location = ?, "
				+ "capacity = ?, poster_filename = ? WHERE event_id = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			setFields(pstmt, event);
			pstmt.setInt(7, event.getEventId());
			return pstmt.executeUpdate() == 1;
		}
	}

	/** 행사를 삭제한다. 그 행사의 참석 신청(attendance)은 외래키 ON DELETE CASCADE 로 함께 지워진다. */
	public boolean delete(int eventId) throws SQLException {
		String sql = "DELETE FROM club_event WHERE event_id = ?";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, eventId);
			return pstmt.executeUpdate() == 1;
		}
	}

	/** insert 와 update 가 함께 쓰는 1~6번 물음표 채우기 */
	private void setFields(PreparedStatement pstmt, Event event) throws SQLException {
		pstmt.setString(1, event.getTitle());
		pstmt.setString(2, event.getDescription());
		pstmt.setTimestamp(3, event.getEventDate());
		pstmt.setString(4, event.getLocation());
		pstmt.setInt(5, event.getCapacity());
		pstmt.setString(6, event.getPosterFilename());
	}

	private ArrayList<Event> selectList(String sql) throws SQLException {
		ArrayList<Event> list = new ArrayList<Event>();
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			while (rs.next()) {
				list.add(toEvent(rs));
			}
		}
		return list;
	}

	/** ResultSet 의 현재 행을 Event 객체로 옮긴다. */
	private Event toEvent(ResultSet rs) throws SQLException {
		Event event = new Event();
		event.setEventId(rs.getInt("event_id"));
		event.setTitle(rs.getString("title"));
		event.setDescription(rs.getString("description"));
		event.setEventDate(rs.getTimestamp("event_date"));
		event.setLocation(rs.getString("location"));
		event.setCapacity(rs.getInt("capacity"));
		event.setPosterFilename(rs.getString("poster_filename"));
		event.setAppliedCount(rs.getInt("applied_count"));
		return event;
	}
}
