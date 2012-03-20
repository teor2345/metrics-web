package org.torproject.ernie.web;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.apache.commons.codec.binary.Base64;

/**
 * Web page that allows users to search for relays in the descriptor
 * archives.
 *
 * Possible search terms for testing:
 * - gabelmoo
 * - gabelmoo 2010-09
 * - gabelmoo 2010-09-18
 * - gabelmoo $F2044413DAC2E02E3D6BCF4735A19BCA1DE97281
 * - gabelmoo 80.190.246
 * - gabelmoo $F2044413DAC2E02E3D6BCF4735A19BCA1DE97281 80.190.246
 * - 5898549205 dc737cc9dca16af6 79.212.74.45
 * - 5898549205 dc737cc9dca16af6
 * - 80.190.246.100
 * - $F2044413DAC2E02E3D6BCF4735A19BCA1DE97281
 * - $F2044413DAC2E02E3D6BCF4735A19BCA1DE97281 80.190.246
 * - 58985492
 * - 58985492 79.212.74.45
 */
public class RelaySearchServlet extends HttpServlet {

  private Pattern alphaNumDotDashDollarSpacePattern =
      Pattern.compile("[A-Za-z0-9\\.\\-$ ]+");

  private Pattern numPattern = Pattern.compile("[0-9]+");

  private Pattern hexPattern = Pattern.compile("[A-Fa-f0-9]+");

  private Pattern alphaNumPattern = Pattern.compile("[A-Za-z0-9]+");

  private SimpleDateFormat dayFormat = new SimpleDateFormat("yyyy-MM-dd");

  private SimpleDateFormat monthFormat = new SimpleDateFormat("yyyy-MM");

  private SimpleDateFormat dateTimeFormat =
      new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  private long minValidAfterMillis;

  private DataSource ds;

  private Logger logger;

  public void init() {

    /* Initialize logger. */
    this.logger = Logger.getLogger(RelaySearchServlet.class.toString());

    /* Initialize date format parsers. */
    dayFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    monthFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    dateTimeFormat.setTimeZone(TimeZone.getTimeZone("UTC"));

    /* Look up data source. */
    try {
      Context cxt = new InitialContext();
      this.ds = (DataSource) cxt.lookup("java:comp/env/jdbc/tordir");
      this.logger.info("Successfully looked up data source.");
    } catch (NamingException e) {
      this.logger.log(Level.WARNING, "Could not look up data source", e);
    }

    /* Look up first consensus in the database. */
    try {
      long requestedConnection = System.currentTimeMillis();
      Connection conn = this.ds.getConnection();
      String query = "SELECT MIN(validafter) AS first FROM consensus";
      Statement statement = conn.createStatement();
      ResultSet rs = statement.executeQuery(query);
      if (rs.next()) {
        this.minValidAfterMillis = rs.getTimestamp(1).getTime();
      }
      rs.close();
      statement.close();
      conn.close();
      this.logger.info("Returned a database connection to the pool "
          + "after " + (System.currentTimeMillis()
          - requestedConnection) + " millis.");
    } catch (SQLException e) {
      this.logger.log(Level.WARNING, "Could not look up first consensus "
          + "valid-after time in the database.", e);
    }
  }

  public void doGet(HttpServletRequest request,
      HttpServletResponse response) throws IOException,
      ServletException {

    /* Read search parameter. If we don't have a search parameter, we're
     * done here. */
    String searchParameter = request.getParameter("search");
    if (searchParameter == null || searchParameter.length() == 0) {
      request.getRequestDispatcher("WEB-INF/relay-search.jsp").forward(
          request, response);
      return;
    }

    /* Parse search parameter to identify what nickname, fingerprint,
     * and/or IP address to search for. A valid query contains no more
     * than one identifier for each of the fields. As a special case,
     * there are search terms consisting of 8 to 19 hex characters that
     * can be either a nickname or a fingerprint. */
    String searchNickname = "";
    String searchFingerprint = "";
    String searchIPAddress = "";
    SortedSet<String> searchDays = new TreeSet<String>();
    SortedSet<String> searchMonths = new TreeSet<String>();
    SortedSet<Long> searchDayTimestamps = new TreeSet<Long>();
    SortedSet<Long> searchMonthTimestamps = new TreeSet<Long>();
    boolean validQuery = false;

    /* Only parse search parameter if it contains nothing else than
     * alphanumeric characters, dots, and spaces. */
    if (alphaNumDotDashDollarSpacePattern.matcher(searchParameter).
        matches()) {
      SortedSet<String> searchTerms = new TreeSet<String>();
      if (searchParameter.trim().contains(" ")) {
        String[] split = searchParameter.trim().split(" ");
        for (int i = 0; i < split.length; i++) {
          if (split[i].length() > 0) {
            searchTerms.add(split[i]);
          }
        }
      } else {
        searchTerms.add(searchParameter.trim());
      }

      /* Parse each search term separately. */
      for (String searchTerm : searchTerms) {

        /* If the search term contains a dot, it can only be an IP
         * address. */
        if (searchTerm.contains(".") && !searchTerm.startsWith(".")) {
          String[] octets = searchTerm.split("\\.");
          if (searchIPAddress.length() > 0 || octets.length < 2 ||
              octets.length > 4) {
            validQuery = false;
            break;
          }
          boolean invalidOctet = false;
          StringBuilder sb = new StringBuilder();
          for (int i = 0; i < octets.length; i++) {
            if (!numPattern.matcher(octets[i]).matches() ||
                octets[i].length() > 3 ||
                Integer.parseInt(octets[i]) > 255) {
              invalidOctet = true;
              break;
            } else {
              sb.append("." + Integer.parseInt(octets[i]));
            }
          }
          if (invalidOctet) {
            validQuery = false;
            break;
          }
          if (octets.length < 4) {
            sb.append(".");
          }
          searchIPAddress = sb.toString().substring(1);
          validQuery = true;
        }

        /* If the search term contains hyphens, it must be a month or a
         * day. */
        else if (searchTerm.contains("-") &&
            searchTerm.startsWith("20")) {
          try {
            if (searchTerm.length() == 10) {
              searchDayTimestamps.add(dayFormat.parse(searchTerm).
                  getTime());
              searchDays.add(searchTerm);
            } else if (searchTerm.length() == 7) {
              searchMonthTimestamps.add(monthFormat.parse(searchTerm).
                  getTime());
              searchMonths.add(searchTerm);
            } else {
              validQuery = false;
              break;
            }
          } catch (ParseException e) {
            validQuery = false;
            break;
          }
        }

        /* If the search term starts with a $ followed by 8 to 40 hex
         * characters, it must be a fingerprint. */
        else if (searchTerm.length() >= 9 && searchTerm.length() <= 41 &&
            searchTerm.startsWith("$") &&
            hexPattern.matcher(searchTerm.substring(1)).matches()) {
          if (searchFingerprint.length() > 0) {
            validQuery = false;
            break;
          }
          searchFingerprint = searchTerm.substring(1);
          validQuery = true;
        }

        /* If the search term contains up to 19 alphanumerical characters,
         * it must be a nickname. */
        else if (searchTerm.length() <= 19 &&
            alphaNumPattern.matcher(searchTerm).matches()) {
          if (searchNickname.length() > 0) {
            validQuery = false;
            break;
          }
          searchNickname = searchTerm;
          validQuery = true;
        }

        /* We didn't recognize this search term. */
        else {
          validQuery = false;
          break;
        }
      }
    }

    /* We only accept at most one month or three days, but not both, or
     * people could accidentally keep the database busy. */
    if (searchDays.size() > 3 || searchMonths.size() > 1 ||
        (searchMonths.size() == 1 && searchDays.size() > 0)) {
      validQuery = false;
    }

    /* If the query is invalid, stop here. */
    if (!validQuery) {
      request.setAttribute("invalidQuery", "Query is invalid.");
      request.getRequestDispatcher("WEB-INF/relay-search.jsp").
          forward(request, response);
      return;
    }

    /* Prepare a string that says what we're searching for. */
    List<String> recognizedSearchTerms = new ArrayList<String>();
    if (searchNickname.length() > 0) {
      recognizedSearchTerms.add("nickname <b>" + searchNickname + "</b>");
    }
    if (searchFingerprint.length() > 0) {
      recognizedSearchTerms.add("fingerprint <b>" + searchFingerprint
          + "</b>");
    }
    if (searchIPAddress.length() > 0) {
      recognizedSearchTerms.add("IP address <b>" + searchIPAddress
          + "</b>");
    }
    List<String> recognizedIntervals = new ArrayList<String>();
    for (String searchTerm : searchMonths) {
      recognizedIntervals.add("in <b>" + searchTerm + "</b>");
    }
    for (String searchTerm : searchDays) {
      recognizedIntervals.add("on <b>" + searchTerm + "</b>");
    }
    StringBuilder searchNoticeBuilder = new StringBuilder();
    searchNoticeBuilder.append("Searching for relays with ");
    if (recognizedSearchTerms.size() == 1) {
      searchNoticeBuilder.append(recognizedSearchTerms.get(0));
    } else if (recognizedSearchTerms.size() == 2) {
      searchNoticeBuilder.append(recognizedSearchTerms.get(0) + " and "
          + recognizedSearchTerms.get(1));
    } else {
      for (int i = 0; i < recognizedSearchTerms.size() - 1; i++) {
        searchNoticeBuilder.append(recognizedSearchTerms.get(i) + ", ");
      }
      searchNoticeBuilder.append("and " + recognizedSearchTerms.get(
          recognizedSearchTerms.size() - 1));
    }
    if (recognizedIntervals.size() == 1) {
      searchNoticeBuilder.append(" running "
          + recognizedIntervals.get(0));
    } else if (recognizedIntervals.size() == 2) {
      searchNoticeBuilder.append(" running " + recognizedIntervals.get(0)
          + " and/or " + recognizedIntervals.get(1));
    } else if (recognizedIntervals.size() > 2) {
      searchNoticeBuilder.append(" running ");
      for (int i = 0; i < recognizedIntervals.size() - 1; i++) {
      searchNoticeBuilder.append(recognizedIntervals.get(i) + ", ");
      }
      searchNoticeBuilder.append("and/or " + recognizedIntervals.get(
          recognizedIntervals.size() - 1));
    }
    searchNoticeBuilder.append(" ...");
    String searchNotice = searchNoticeBuilder.toString();
    request.setAttribute("searchNotice", searchNotice);

    /* Prepare the query string. */
    StringBuilder conditionBuilder = new StringBuilder();
    boolean addAnd = false;
    if (searchNickname.length() > 0) {
      conditionBuilder.append((addAnd ? "AND " : "")
          + "LOWER(nickname) LIKE '" + searchNickname.toLowerCase()
          + "%' ");
      addAnd = true;
    }
    if (searchFingerprint.length() > 0) {
      conditionBuilder.append((addAnd ? "AND " : "")
          + "fingerprint LIKE '" + searchFingerprint.toLowerCase()
          + "%' ");
      addAnd = true;
    }
    if (searchIPAddress.length() > 0) {
      conditionBuilder.append((addAnd ? "AND " : "")
          + "address LIKE '" + searchIPAddress + "%' ");
      addAnd = true;
    }
    List<String> timeIntervals = new ArrayList<String>();
    if (searchDayTimestamps.size() > 0 ||
        searchMonthTimestamps.size() > 0) {
      StringBuilder timeIntervalBuilder = new StringBuilder();
      boolean addOr = false;
      timeIntervalBuilder.append("AND (");
      for (long searchTimestamp : searchDayTimestamps) {
        if (searchTimestamp < this.minValidAfterMillis) {
          request.setAttribute("outsideInterval", "Returned search "
              + "results may be incomplete, as our data only dates back "
              + "to " + dateTimeFormat.format(this.minValidAfterMillis)
              + ".  Older archives are not available.");
        }
        timeIntervalBuilder.append((addOr ? "OR " : "")
            + "(validafter >= '"
            + dateTimeFormat.format(searchTimestamp) + "' AND "
            + "validafter < '" + dateTimeFormat.format(searchTimestamp
            + 24L * 60L * 60L * 1000L) + "') ");
        addOr = true;
      }
      for (long searchTimestamp : searchMonthTimestamps) {
        if (searchTimestamp < this.minValidAfterMillis) {
          request.setAttribute("outsideInterval", "Returned search "
              + "results may be incomplete, as our data only dates back "
              + "to " + dateTimeFormat.format(this.minValidAfterMillis)
              + ".  Older archives are not available.");
        }
        Calendar firstOfNextMonth = Calendar.getInstance(
            TimeZone.getTimeZone("UTC"));
        firstOfNextMonth.setTimeInMillis(searchTimestamp);
        firstOfNextMonth.add(Calendar.MONTH, 1);
        timeIntervalBuilder.append((addOr ? "OR " : "")
            + "(validafter >= '"
            + dateTimeFormat.format(searchTimestamp) + "' AND "
            + "validafter < '" + dateTimeFormat.format(
            firstOfNextMonth.getTimeInMillis()) + "') ");
        addOr = true;
      }
      timeIntervalBuilder.append(") ");
      timeIntervals.add(timeIntervalBuilder.toString());
    } else {
      timeIntervals.add("AND validafter >= '"
          + dateTimeFormat.format(System.currentTimeMillis()
          - 4L * 24L * 60L * 60L * 1000L) + "' ");
      timeIntervals.add("AND validafter >= '"
          + dateTimeFormat.format(System.currentTimeMillis()
          - 30L * 24L * 60L * 60L * 1000L) + "' ");
    }
    List<String> queries = new ArrayList<String>();
    for (String timeInterval : timeIntervals) {
      StringBuilder queryBuilder = new StringBuilder();
      queryBuilder.append("SELECT validafter, fingerprint, descriptor, "
          + "rawdesc FROM statusentry WHERE validafter IN (SELECT "
          + "validafter FROM statusentry WHERE ");
      queryBuilder.append(conditionBuilder.toString());
      queryBuilder.append(timeInterval);
      queryBuilder.append("ORDER BY validafter DESC LIMIT 31) AND ");
      queryBuilder.append(conditionBuilder.toString());
      queryBuilder.append(timeInterval);
      queries.add(queryBuilder.toString());
    }

    /* Actually execute the query. */
    long startedQuery = System.currentTimeMillis();
    SortedMap<String, SortedSet<String>> foundDescriptors =
        new TreeMap<String, SortedSet<String>>(
        Collections.reverseOrder());
    Map<String, String> rawValidAfterLines =
        new HashMap<String, String>();
    Map<String, String> rawStatusEntries = new HashMap<String, String>();
    String query = null;
    int matches = 0;
    try {
      long requestedConnection = System.currentTimeMillis();
      Connection conn = this.ds.getConnection();
      while (!queries.isEmpty()) {
        query = queries.remove(0);
        this.logger.info("Running query '" + query + "'.");
        Statement statement = conn.createStatement();
        ResultSet rs = statement.executeQuery(query);
        while (rs.next()) {
          matches++;
          String validAfter = rs.getTimestamp(1).toString().
              substring(0, 19);
          String fingerprint = rs.getString(2);
          String descriptor = rs.getString(3);
          if (!foundDescriptors.containsKey(validAfter)) {
            foundDescriptors.put(validAfter, new TreeSet<String>());
          }
          foundDescriptors.get(validAfter).add(validAfter + " "
              + fingerprint);
          if (!rawValidAfterLines.containsKey(validAfter)) {
            rawValidAfterLines.put(validAfter, "<tt>valid-after "
                + "<a href=\"consensus?valid-after="
                + validAfter.replaceAll(":", "-").replaceAll(" ", "-")
                + "\" target=\"_blank\">" + validAfter + "</a></tt><br>");
          }
          byte[] rawStatusEntry = rs.getBytes(4);
          String statusEntryLines = null;
          try {
            statusEntryLines = new String(rawStatusEntry, "US-ASCII");
          } catch (UnsupportedEncodingException e) {
            /* This shouldn't happen, because we know that ASCII is
             * supported. */
          }
          StringBuilder rawStatusEntryBuilder = new StringBuilder();
          String[] lines = statusEntryLines.split("\n");
          for (String line : lines) {
            if (line.startsWith("r ")) {
              String[] parts = line.split(" ");
              String descriptorBase64 = String.format("%040x",
                  new BigInteger(1, Base64.decodeBase64(parts[3]
                  + "==")));
              rawStatusEntryBuilder.append("<tt>r " + parts[1] + " "
                  + parts[2] + " <a href=\"serverdesc?desc-id="
                  + descriptorBase64 + "\" target=\"_blank\">" + parts[3]
                  + "</a> " + parts[4] + " " + parts[5] + " " + parts[6]
                  + " " + parts[7] + " " + parts[8] + "</tt><br>");
            } else {
              rawStatusEntryBuilder.append("<tt>" + line + "</tt><br>");
            }
          }
          rawStatusEntries.put(validAfter + " " + fingerprint,
                rawStatusEntryBuilder.toString());
        }
        rs.close();
        statement.close();
        if (matches >= 31) {
          queries.clear();
        }
      }
      conn.close();
      this.logger.info("Returned a database connection to the pool "
          + "after " + (System.currentTimeMillis()
          - requestedConnection) + " millis.");
    } catch (SQLException e) {

      /* Tell the user we have a database problem. */
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
          "Database problem");
      return;
    }
    request.setAttribute("query", query);
    request.setAttribute("queryTime", System.currentTimeMillis()
        - startedQuery);
    request.setAttribute("foundDescriptors", foundDescriptors);
    request.setAttribute("rawValidAfterLines", rawValidAfterLines);
    request.setAttribute("rawStatusEntries", rawStatusEntries);
    request.setAttribute("matches", matches);

    /* We're done. Let the JSP do the rest. */
    request.getRequestDispatcher("WEB-INF/relay-search.jsp").forward(
        request, response);
  }
}

