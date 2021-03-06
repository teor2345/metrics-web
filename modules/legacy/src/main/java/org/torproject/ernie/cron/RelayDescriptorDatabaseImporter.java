/* Copyright 2011--2017 The Tor Project
 * See LICENSE for licensing information */

package org.torproject.ernie.cron;

import org.torproject.descriptor.Descriptor;
import org.torproject.descriptor.DescriptorReader;
import org.torproject.descriptor.DescriptorSourceFactory;
import org.torproject.descriptor.ExtraInfoDescriptor;
import org.torproject.descriptor.NetworkStatusEntry;
import org.torproject.descriptor.RelayNetworkStatusConsensus;
import org.torproject.descriptor.ServerDescriptor;

import org.postgresql.util.PGbytea;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TimeZone;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Parse directory data.
 */

/* TODO Split up this class and move its parts to cron.network,
 * cron.users, and status.relaysearch packages.  Requires extensive
 * changes to the database schema though. */
public final class RelayDescriptorDatabaseImporter {

  /**
   * How many records to commit with each database transaction.
   */
  private final long autoCommitCount = 500;

  /* Counters to keep track of the number of records committed before
   * each transaction. */

  private int rdsCount = 0;

  private int resCount = 0;

  private int rhsCount = 0;

  private int rrsCount = 0;

  private int rcsCount = 0;

  private int rvsCount = 0;

  private int rqsCount = 0;

  /**
   * Relay descriptor database connection.
   */
  private Connection conn;

  /**
   * Prepared statement to check whether any network status consensus
   * entries matching a given valid-after time have been imported into the
   * database before.
   */
  private PreparedStatement psSs;

  /**
   * Prepared statement to check whether a given server descriptor has
   * been imported into the database before.
   */
  private PreparedStatement psDs;

  /**
   * Prepared statement to check whether a given network status consensus
   * has been imported into the database before.
   */
  private PreparedStatement psCs;

  /**
   * Set of dates that have been inserted into the database for being
   * included in the next refresh run.
   */
  private Set<Long> scheduledUpdates;

  /**
   * Prepared statement to insert a date into the database that shall be
   * included in the next refresh run.
   */
  private PreparedStatement psU;

  /**
   * Prepared statement to insert a network status consensus entry into
   * the database.
   */
  private PreparedStatement psR;

  /**
   * Prepared statement to insert a server descriptor into the database.
   */
  private PreparedStatement psD;

  /**
   * Callable statement to insert the bandwidth history of an extra-info
   * descriptor into the database.
   */
  private CallableStatement csH;

  /**
   * Prepared statement to insert a network status consensus into the
   * database.
   */
  private PreparedStatement psC;

  /**
   * Logger for this class.
   */
  private Logger logger;

  /**
   * Directory for writing raw import files.
   */
  private String rawFilesDirectory;

  /**
   * Raw import file containing status entries.
   */
  private BufferedWriter statusentryOut;

  /**
   * Raw import file containing server descriptors.
   */
  private BufferedWriter descriptorOut;

  /**
   * Raw import file containing bandwidth histories.
   */
  private BufferedWriter bwhistOut;

  /**
   * Raw import file containing consensuses.
   */
  private BufferedWriter consensusOut;

  /**
   * Date format to parse timestamps.
   */
  private SimpleDateFormat dateTimeFormat;

  /**
   * The last valid-after time for which we checked whether they have been
   * any network status entries in the database.
   */
  private long lastCheckedStatusEntries;

  /**
   * Set of fingerprints that we imported for the valid-after time in
   * <code>lastCheckedStatusEntries</code>.
   */
  private Set<String> insertedStatusEntries = new HashSet<>();

  private boolean importIntoDatabase;

  private boolean writeRawImportFiles;

  private List<File> archivesDirectories;

  private File statsDirectory;

  private boolean keepImportHistory;

  /**
   * Initialize database importer by connecting to the database and
   * preparing statements.
   */
  public RelayDescriptorDatabaseImporter(String connectionUrl,
      String rawFilesDirectory, List<File> archivesDirectories,
      File statsDirectory, boolean keepImportHistory) {

    if (archivesDirectories == null || statsDirectory == null) {
      throw new IllegalArgumentException();
    }
    this.archivesDirectories = archivesDirectories;
    this.statsDirectory = statsDirectory;
    this.keepImportHistory = keepImportHistory;

    /* Initialize logger. */
    this.logger = Logger.getLogger(
        RelayDescriptorDatabaseImporter.class.getName());

    if (connectionUrl != null) {
      try {
        /* Connect to database. */
        this.conn = DriverManager.getConnection(connectionUrl);

        /* Turn autocommit off */
        this.conn.setAutoCommit(false);

        /* Prepare statements. */
        this.psSs = conn.prepareStatement("SELECT fingerprint "
            + "FROM statusentry WHERE validafter = ?");
        this.psDs = conn.prepareStatement("SELECT COUNT(*) "
            + "FROM descriptor WHERE descriptor = ?");
        this.psCs = conn.prepareStatement("SELECT COUNT(*) "
            + "FROM consensus WHERE validafter = ?");
        this.psR = conn.prepareStatement("INSERT INTO statusentry "
            + "(validafter, nickname, fingerprint, descriptor, "
            + "published, address, orport, dirport, isauthority, "
            + "isbadexit, isbaddirectory, isexit, isfast, isguard, "
            + "ishsdir, isnamed, isstable, isrunning, isunnamed, "
            + "isvalid, isv2dir, isv3dir, version, bandwidth, ports, "
            + "rawdesc) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "
            + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        this.psD = conn.prepareStatement("INSERT INTO descriptor "
            + "(descriptor, nickname, address, orport, dirport, "
            + "fingerprint, bandwidthavg, bandwidthburst, "
            + "bandwidthobserved, platform, published, uptime, "
            + "extrainfo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "
            + "?)");
        this.csH = conn.prepareCall("{call insert_bwhist(?, ?, ?, ?, ?, "
            + "?)}");
        this.psC = conn.prepareStatement("INSERT INTO consensus "
            + "(validafter) VALUES (?)");
        this.psU = conn.prepareStatement("INSERT INTO scheduled_updates "
            + "(date) VALUES (?)");
        this.scheduledUpdates = new HashSet<>();
        this.importIntoDatabase = true;
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not connect to database or "
            + "prepare statements.", e);
      }
    }

    /* Remember where we want to write raw import files. */
    if (rawFilesDirectory != null) {
      this.rawFilesDirectory = rawFilesDirectory;
      this.writeRawImportFiles = true;
    }

    /* Initialize date format, so that we can format timestamps. */
    this.dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    this.dateTimeFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
  }

  private void addDateToScheduledUpdates(long timestamp)
      throws SQLException {
    if (!this.importIntoDatabase) {
      return;
    }
    long dateMillis;
    try {
      dateMillis = this.dateTimeFormat.parse(
          this.dateTimeFormat.format(timestamp).substring(0, 10)
          + " 00:00:00").getTime();
    } catch (ParseException e) {
      this.logger.log(Level.WARNING, "Internal parsing error.", e);
      return;
    }
    if (!this.scheduledUpdates.contains(dateMillis)) {
      this.psU.setDate(1, new java.sql.Date(dateMillis));
      this.psU.execute();
      this.scheduledUpdates.add(dateMillis);
    }
  }

  /**
   * Insert network status consensus entry into database.
   */
  public void addStatusEntryContents(long validAfter, String nickname,
      String fingerprint, String descriptor, long published,
      String address, long orPort, long dirPort,
      SortedSet<String> flags, String version, long bandwidth,
      String ports, byte[] rawDescriptor) {
    if (this.importIntoDatabase) {
      try {
        this.addDateToScheduledUpdates(validAfter);
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        Timestamp validAfterTimestamp = new Timestamp(validAfter);
        if (lastCheckedStatusEntries != validAfter) {
          insertedStatusEntries.clear();
          this.psSs.setTimestamp(1, validAfterTimestamp, cal);
          ResultSet rs = psSs.executeQuery();
          while (rs.next()) {
            String insertedFingerprint = rs.getString(1);
            insertedStatusEntries.add(insertedFingerprint);
          }
          rs.close();
          lastCheckedStatusEntries = validAfter;
        }
        if (!insertedStatusEntries.contains(fingerprint)) {
          this.psR.clearParameters();
          this.psR.setTimestamp(1, validAfterTimestamp, cal);
          this.psR.setString(2, nickname);
          this.psR.setString(3, fingerprint);
          this.psR.setString(4, descriptor);
          this.psR.setTimestamp(5, new Timestamp(published), cal);
          this.psR.setString(6, address);
          this.psR.setLong(7, orPort);
          this.psR.setLong(8, dirPort);
          this.psR.setBoolean(9, flags.contains("Authority"));
          this.psR.setBoolean(10, flags.contains("BadExit"));
          this.psR.setBoolean(11, flags.contains("BadDirectory"));
          this.psR.setBoolean(12, flags.contains("Exit"));
          this.psR.setBoolean(13, flags.contains("Fast"));
          this.psR.setBoolean(14, flags.contains("Guard"));
          this.psR.setBoolean(15, flags.contains("HSDir"));
          this.psR.setBoolean(16, flags.contains("Named"));
          this.psR.setBoolean(17, flags.contains("Stable"));
          this.psR.setBoolean(18, flags.contains("Running"));
          this.psR.setBoolean(19, flags.contains("Unnamed"));
          this.psR.setBoolean(20, flags.contains("Valid"));
          this.psR.setBoolean(21, flags.contains("V2Dir"));
          this.psR.setBoolean(22, flags.contains("V3Dir"));
          this.psR.setString(23, version);
          this.psR.setLong(24, bandwidth);
          this.psR.setString(25, ports);
          this.psR.setBytes(26, rawDescriptor);
          this.psR.executeUpdate();
          rrsCount++;
          if (rrsCount % autoCommitCount == 0)  {
            this.conn.commit();
          }
          insertedStatusEntries.add(fingerprint);
        }
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not add network status "
            + "consensus entry.  We won't make any further SQL requests "
            + "in this execution.", e);
        this.importIntoDatabase = false;
      }
    }
    if (this.writeRawImportFiles) {
      try {
        if (this.statusentryOut == null) {
          new File(rawFilesDirectory).mkdirs();
          this.statusentryOut = new BufferedWriter(new FileWriter(
              rawFilesDirectory + "/statusentry.sql"));
          this.statusentryOut.write(" COPY statusentry (validafter, "
              + "nickname, fingerprint, descriptor, published, address, "
              + "orport, dirport, isauthority, isbadExit, "
              + "isbaddirectory, isexit, isfast, isguard, ishsdir, "
              + "isnamed, isstable, isrunning, isunnamed, isvalid, "
              + "isv2dir, isv3dir, version, bandwidth, ports, rawdesc) "
              + "FROM stdin;\n");
        }
        this.statusentryOut.write(
            this.dateTimeFormat.format(validAfter) + "\t" + nickname
            + "\t" + fingerprint.toLowerCase() + "\t"
            + descriptor.toLowerCase() + "\t"
            + this.dateTimeFormat.format(published) + "\t" + address
            + "\t" + orPort + "\t" + dirPort + "\t"
            + (flags.contains("Authority") ? "t" : "f") + "\t"
            + (flags.contains("BadExit") ? "t" : "f") + "\t"
            + (flags.contains("BadDirectory") ? "t" : "f") + "\t"
            + (flags.contains("Exit") ? "t" : "f") + "\t"
            + (flags.contains("Fast") ? "t" : "f") + "\t"
            + (flags.contains("Guard") ? "t" : "f") + "\t"
            + (flags.contains("HSDir") ? "t" : "f") + "\t"
            + (flags.contains("Named") ? "t" : "f") + "\t"
            + (flags.contains("Stable") ? "t" : "f") + "\t"
            + (flags.contains("Running") ? "t" : "f") + "\t"
            + (flags.contains("Unnamed") ? "t" : "f") + "\t"
            + (flags.contains("Valid") ? "t" : "f") + "\t"
            + (flags.contains("V2Dir") ? "t" : "f") + "\t"
            + (flags.contains("V3Dir") ? "t" : "f") + "\t"
            + (version != null ? version : "\\N") + "\t"
            + (bandwidth >= 0 ? bandwidth : "\\N") + "\t"
            + (ports != null ? ports : "\\N") + "\t");
        this.statusentryOut.write(PGbytea.toPGString(rawDescriptor)
            .replaceAll("\\\\", "\\\\\\\\") + "\n");
      } catch (SQLException | IOException e) {
        this.logger.log(Level.WARNING, "Could not write network status "
            + "consensus entry to raw database import file.  We won't "
            + "make any further attempts to write raw import files in "
            + "this execution.", e);
        this.writeRawImportFiles = false;
      }
    }
  }

  /**
   * Insert server descriptor into database.
   */
  public void addServerDescriptorContents(String descriptor,
      String nickname, String address, int orPort, int dirPort,
      String relayIdentifier, long bandwidthAvg, long bandwidthBurst,
      long bandwidthObserved, String platform, long published,
      Long uptime, String extraInfoDigest) {
    if (this.importIntoDatabase) {
      try {
        this.addDateToScheduledUpdates(published);
        this.addDateToScheduledUpdates(
            published + 24L * 60L * 60L * 1000L);
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        this.psDs.setString(1, descriptor);
        ResultSet rs = psDs.executeQuery();
        rs.next();
        if (rs.getInt(1) == 0) {
          this.psD.clearParameters();
          this.psD.setString(1, descriptor);
          this.psD.setString(2, nickname);
          this.psD.setString(3, address);
          this.psD.setInt(4, orPort);
          this.psD.setInt(5, dirPort);
          this.psD.setString(6, relayIdentifier);
          this.psD.setLong(7, bandwidthAvg);
          this.psD.setLong(8, bandwidthBurst);
          this.psD.setLong(9, bandwidthObserved);
          /* Remove all non-ASCII characters from the platform string, or
           * we'll make Postgres unhappy.  Sun's JDK and OpenJDK behave
           * differently when creating a new String with a given encoding.
           * That's what the regexp below is for. */
          this.psD.setString(10, new String(platform.getBytes(),
              StandardCharsets.US_ASCII).replaceAll("[^\\p{ASCII}]",""));
          this.psD.setTimestamp(11, new Timestamp(published), cal);
          if (null != uptime) {
            this.psD.setLong(12, uptime);
          } else {
            this.psD.setNull(12, Types.BIGINT);
          }
          this.psD.setString(13, extraInfoDigest);
          this.psD.executeUpdate();
          rdsCount++;
          if (rdsCount % autoCommitCount == 0)  {
            this.conn.commit();
          }
        }
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not add server "
            + "descriptor.  We won't make any further SQL requests in "
            + "this execution.", e);
        this.importIntoDatabase = false;
      }
    }
    if (this.writeRawImportFiles) {
      try {
        if (this.descriptorOut == null) {
          new File(rawFilesDirectory).mkdirs();
          this.descriptorOut = new BufferedWriter(new FileWriter(
              rawFilesDirectory + "/descriptor.sql"));
          this.descriptorOut.write(" COPY descriptor (descriptor, "
              + "nickname, address, orport, dirport, fingerprint, "
              + "bandwidthavg, bandwidthburst, bandwidthobserved, "
              + "platform, published, uptime, extrainfo) FROM stdin;\n");
        }
        this.descriptorOut.write(descriptor.toLowerCase() + "\t"
            + nickname + "\t" + address + "\t" + orPort + "\t" + dirPort
            + "\t" + relayIdentifier + "\t" + bandwidthAvg + "\t"
            + bandwidthBurst + "\t" + bandwidthObserved + "\t"
            + (platform != null && platform.length() > 0
            ? new String(platform.getBytes(), StandardCharsets.US_ASCII)
            : "\\N") + "\t" + this.dateTimeFormat.format(published) + "\t"
            + (uptime >= 0 ? uptime : "\\N") + "\t"
            + (extraInfoDigest != null ? extraInfoDigest : "\\N")
            + "\n");
      } catch (IOException e) {
        this.logger.log(Level.WARNING, "Could not write server "
            + "descriptor to raw database import file.  We won't make "
            + "any further attempts to write raw import files in this "
            + "execution.", e);
        this.writeRawImportFiles = false;
      }
    }
  }

  /**
   * Insert extra-info descriptor into database.
   */
  public void addExtraInfoDescriptorContents(String extraInfoDigest,
      String nickname, String fingerprint, long published,
      List<String> bandwidthHistoryLines) {
    if (!bandwidthHistoryLines.isEmpty()) {
      this.addBandwidthHistory(fingerprint.toLowerCase(), published,
          bandwidthHistoryLines);
    }
  }

  private static class BigIntArray implements java.sql.Array {

    private final String stringValue;

    public BigIntArray(long[] array, int offset) {
      if (array == null) {
        this.stringValue = "[-1:-1]={0}";
      } else {
        StringBuilder sb = new StringBuilder("[" + offset + ":"
            + (offset + array.length - 1) + "]={");
        for (int i = 0; i < array.length; i++) {
          sb.append(i > 0 ? "," : "").append(array[i]);
        }
        sb.append('}');
        this.stringValue = sb.toString();
      }
    }

    public String toString() {
      return stringValue;
    }

    public String getBaseTypeName() {
      return "int8";
    }

    /* The other methods are never called; no need to implement them. */
    public void free() {
      throw new UnsupportedOperationException();
    }

    public Object getArray() {
      throw new UnsupportedOperationException();
    }

    public Object getArray(long index, int count) {
      throw new UnsupportedOperationException();
    }

    public Object getArray(long index, int count,
        Map<String, Class<?>> map) {
      throw new UnsupportedOperationException();
    }

    public Object getArray(Map<String, Class<?>> map) {
      throw new UnsupportedOperationException();
    }

    public int getBaseType() {
      throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet() {
      throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet(long index, int count) {
      throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet(long index, int count,
        Map<String, Class<?>> map) {
      throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet(Map<String, Class<?>> map) {
      throw new UnsupportedOperationException();
    }
  }

  /** Inserts a bandwidth history into database. */
  public void addBandwidthHistory(String fingerprint, long published,
      List<String> bandwidthHistoryStrings) {

    /* Split history lines by date and rewrite them so that the date
     * comes first. */
    SortedSet<String> historyLinesByDate = new TreeSet<>();
    for (String bandwidthHistoryString : bandwidthHistoryStrings) {
      String[] parts = bandwidthHistoryString.split(" ");
      if (parts.length != 6) {
        this.logger.finer("Bandwidth history line does not have expected "
            + "number of elements. Ignoring this line.");
        continue;
      }
      long intervalLength;
      try {
        intervalLength = Long.parseLong(parts[3].substring(1));
      } catch (NumberFormatException e) {
        this.logger.fine("Bandwidth history line does not have valid "
            + "interval length '" + parts[3] + " " + parts[4] + "'. "
            + "Ignoring this line.");
        continue;
      }
      String[] values = parts[5].split(",");
      if (intervalLength % 900L != 0L) {
        this.logger.fine("Bandwidth history line does not contain "
            + "multiples of 15-minute intervals. Ignoring this line.");
        continue;
      } else if (intervalLength != 900L) {
        /* This is a really dirty hack to support bandwidth history
         * intervals that are longer than 15 minutes by linearly
         * distributing reported bytes to 15 minute intervals.  The
         * alternative would have been to modify the database schema. */
        try {
          long factor = intervalLength / 900L;
          String[] newValues = new String[values.length * (int) factor];
          for (int i = 0; i < newValues.length; i++) {
            newValues[i] = String.valueOf(
                Long.parseLong(values[i / (int) factor]) / factor);
          }
          values = newValues;
          intervalLength = 900L;
        } catch (NumberFormatException e) {
          this.logger.fine("Number format exception while parsing "
              + "bandwidth history line. Ignoring this line.");
          continue;
        }
      }
      String type = parts[0];
      String intervalEndTime = parts[1] + " " + parts[2];
      long intervalEnd;
      long dateStart;
      try {
        intervalEnd = dateTimeFormat.parse(intervalEndTime).getTime();
        dateStart = dateTimeFormat.parse(parts[1] + " 00:00:00")
            .getTime();
      } catch (ParseException e) {
        this.logger.fine("Parse exception while parsing timestamp in "
            + "bandwidth history line. Ignoring this line.");
        continue;
      }
      if (Math.abs(published - intervalEnd)
          > 7L * 24L * 60L * 60L * 1000L) {
        this.logger.fine("Extra-info descriptor publication time "
            + dateTimeFormat.format(published) + " and last interval "
            + "time " + intervalEndTime + " in " + type + " line differ "
            + "by more than 7 days! Not adding this line!");
        continue;
      }
      long currentIntervalEnd = intervalEnd;
      StringBuilder sb = new StringBuilder();
      SortedSet<String> newHistoryLines = new TreeSet<>();
      try {
        for (int i = values.length - 1; i >= -1; i--) {
          if (i == -1 || currentIntervalEnd < dateStart) {
            sb.insert(0, intervalEndTime + " " + type + " ("
                + intervalLength + " s) ");
            sb.setLength(sb.length() - 1);
            String historyLine = sb.toString();
            newHistoryLines.add(historyLine);
            sb = new StringBuilder();
            dateStart -= 24L * 60L * 60L * 1000L;
            intervalEndTime = dateTimeFormat.format(currentIntervalEnd);
          }
          if (i == -1) {
            break;
          }
          Long.parseLong(values[i]);
          sb.insert(0, values[i] + ",");
          currentIntervalEnd -= intervalLength * 1000L;
        }
      } catch (NumberFormatException e) {
        this.logger.fine("Number format exception while parsing "
            + "bandwidth history line. Ignoring this line.");
        continue;
      }
      historyLinesByDate.addAll(newHistoryLines);
    }

    /* Add split history lines to database. */
    String lastDate = null;
    historyLinesByDate.add("EOL");
    long[] readArray = null;
    long[] writtenArray = null;
    long[] dirreadArray = null;
    long[] dirwrittenArray = null;
    int readOffset = 0;
    int writtenOffset = 0;
    int dirreadOffset = 0;
    int dirwrittenOffset = 0;
    for (String historyLine : historyLinesByDate) {
      String[] parts = historyLine.split(" ");
      String currentDate = parts[0];
      if (lastDate != null && (historyLine.equals("EOL")
          || !currentDate.equals(lastDate))) {
        BigIntArray readIntArray = new BigIntArray(readArray,
            readOffset);
        BigIntArray writtenIntArray = new BigIntArray(writtenArray,
            writtenOffset);
        BigIntArray dirreadIntArray = new BigIntArray(dirreadArray,
            dirreadOffset);
        BigIntArray dirwrittenIntArray = new BigIntArray(dirwrittenArray,
            dirwrittenOffset);
        if (this.importIntoDatabase) {
          try {
            long dateMillis = dateTimeFormat.parse(lastDate
                + " 00:00:00").getTime();
            this.addDateToScheduledUpdates(dateMillis);
            this.csH.setString(1, fingerprint);
            this.csH.setDate(2, new java.sql.Date(dateMillis));
            this.csH.setArray(3, readIntArray);
            this.csH.setArray(4, writtenIntArray);
            this.csH.setArray(5, dirreadIntArray);
            this.csH.setArray(6, dirwrittenIntArray);
            this.csH.addBatch();
            rhsCount++;
            if (rhsCount % autoCommitCount == 0)  {
              this.csH.executeBatch();
            }
          } catch (SQLException | ParseException e) {
            this.logger.log(Level.WARNING, "Could not insert bandwidth "
                + "history line into database.  We won't make any "
                + "further SQL requests in this execution.", e);
            this.importIntoDatabase = false;
          }
        }
        if (this.writeRawImportFiles) {
          try {
            if (this.bwhistOut == null) {
              new File(rawFilesDirectory).mkdirs();
              this.bwhistOut = new BufferedWriter(new FileWriter(
                  rawFilesDirectory + "/bwhist.sql"));
            }
            this.bwhistOut.write("SELECT insert_bwhist('" + fingerprint
                + "','" + lastDate + "','" + readIntArray.toString()
                + "','" + writtenIntArray.toString() + "','"
                + dirreadIntArray.toString() + "','"
                + dirwrittenIntArray.toString() + "');\n");
          } catch (IOException e) {
            this.logger.log(Level.WARNING, "Could not write bandwidth "
                + "history to raw database import file.  We won't make "
                + "any further attempts to write raw import files in "
                + "this execution.", e);
            this.writeRawImportFiles = false;
          }
        }
        readArray = writtenArray = dirreadArray = dirwrittenArray = null;
      }
      if (historyLine.equals("EOL")) {
        break;
      }
      long lastIntervalTime;
      try {
        lastIntervalTime = dateTimeFormat.parse(parts[0] + " "
            + parts[1]).getTime() - dateTimeFormat.parse(parts[0]
            + " 00:00:00").getTime();
      } catch (ParseException e) {
        continue;
      }
      String[] stringValues = parts[5].split(",");
      long[] longValues = new long[stringValues.length];
      for (int i = 0; i < longValues.length; i++) {
        longValues[i] = Long.parseLong(stringValues[i]);
      }

      int offset = (int) (lastIntervalTime / (15L * 60L * 1000L))
          - longValues.length + 1;
      String type = parts[2];
      switch (type) {
        case "read-history":
          readArray = longValues;
          readOffset = offset;
          break;
        case "write-history":
          writtenArray = longValues;
          writtenOffset = offset;
          break;
        case "dirreq-read-history":
          dirreadArray = longValues;
          dirreadOffset = offset;
          break;
        case "dirreq-write-history":
          dirwrittenArray = longValues;
          dirwrittenOffset = offset;
          break;
        default:
          /* Ignore any other types. */
      }
      lastDate = currentDate;
    }
  }

  /**
   * Insert network status consensus into database.
   */
  public void addConsensus(long validAfter) {
    if (this.importIntoDatabase) {
      try {
        this.addDateToScheduledUpdates(validAfter);
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        Timestamp validAfterTimestamp = new Timestamp(validAfter);
        this.psCs.setTimestamp(1, validAfterTimestamp, cal);
        ResultSet rs = psCs.executeQuery();
        rs.next();
        if (rs.getInt(1) == 0) {
          this.psC.clearParameters();
          this.psC.setTimestamp(1, validAfterTimestamp, cal);
          this.psC.executeUpdate();
          rcsCount++;
          if (rcsCount % autoCommitCount == 0)  {
            this.conn.commit();
          }
        }
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not add network status "
            + "consensus.  We won't make any further SQL requests in "
            + "this execution.", e);
        this.importIntoDatabase = false;
      }
    }
    if (this.writeRawImportFiles) {
      try {
        if (this.consensusOut == null) {
          new File(rawFilesDirectory).mkdirs();
          this.consensusOut = new BufferedWriter(new FileWriter(
              rawFilesDirectory + "/consensus.sql"));
          this.consensusOut.write(" COPY consensus (validafter) "
              + "FROM stdin;\n");
        }
        String validAfterString = this.dateTimeFormat.format(validAfter);
        this.consensusOut.write(validAfterString + "\n");
      } catch (IOException e) {
        this.logger.log(Level.WARNING, "Could not write network status "
            + "consensus to raw database import file.  We won't make "
            + "any further attempts to write raw import files in this "
            + "execution.", e);
        this.writeRawImportFiles = false;
      }
    }
  }

  /** Imports relay descriptors into the database. */
  public void importRelayDescriptors() {
    logger.fine("Importing files in directories " + archivesDirectories
        + "/...");
    if (!this.archivesDirectories.isEmpty()) {
      DescriptorReader reader =
          DescriptorSourceFactory.createDescriptorReader();
      reader.setMaxDescriptorsInQueue(10);
      File historyFile = new File(statsDirectory,
          "database-importer-relay-descriptor-history");
      if (keepImportHistory) {
        reader.setHistoryFile(historyFile);
      }
      for (Descriptor descriptor : reader.readDescriptors(
          this.archivesDirectories.toArray(
          new File[this.archivesDirectories.size()]))) {
        if (descriptor instanceof RelayNetworkStatusConsensus) {
          this.addRelayNetworkStatusConsensus(
              (RelayNetworkStatusConsensus) descriptor);
        } else if (descriptor instanceof ServerDescriptor) {
          this.addServerDescriptor((ServerDescriptor) descriptor);
        } else if (descriptor instanceof ExtraInfoDescriptor) {
          this.addExtraInfoDescriptor((ExtraInfoDescriptor) descriptor);
        }
      }
      if (keepImportHistory) {
        reader.saveHistoryFile(historyFile);
      }
    }

    logger.info("Finished importing relay descriptors.");
  }

  private void addRelayNetworkStatusConsensus(
      RelayNetworkStatusConsensus consensus) {
    for (NetworkStatusEntry statusEntry
        : consensus.getStatusEntries().values()) {
      this.addStatusEntryContents(consensus.getValidAfterMillis(),
          statusEntry.getNickname(),
          statusEntry.getFingerprint().toLowerCase(),
          statusEntry.getDescriptor().toLowerCase(),
          statusEntry.getPublishedMillis(), statusEntry.getAddress(),
          statusEntry.getOrPort(), statusEntry.getDirPort(),
          statusEntry.getFlags(), statusEntry.getVersion(),
          statusEntry.getBandwidth(), statusEntry.getPortList(),
          statusEntry.getStatusEntryBytes());
    }
    this.addConsensus(consensus.getValidAfterMillis());
  }

  private void addServerDescriptor(ServerDescriptor descriptor) {
    this.addServerDescriptorContents(
        descriptor.getDigestSha1Hex(), descriptor.getNickname(),
        descriptor.getAddress(), descriptor.getOrPort(),
        descriptor.getDirPort(), descriptor.getFingerprint(),
        descriptor.getBandwidthRate(), descriptor.getBandwidthBurst(),
        descriptor.getBandwidthObserved(), descriptor.getPlatform(),
        descriptor.getPublishedMillis(), descriptor.getUptime(),
        descriptor.getExtraInfoDigestSha1Hex());
  }

  private void addExtraInfoDescriptor(ExtraInfoDescriptor descriptor) {
    List<String> bandwidthHistoryLines = new ArrayList<>();
    if (descriptor.getWriteHistory() != null) {
      bandwidthHistoryLines.add(descriptor.getWriteHistory().getLine());
    }
    if (descriptor.getReadHistory() != null) {
      bandwidthHistoryLines.add(descriptor.getReadHistory().getLine());
    }
    if (descriptor.getDirreqWriteHistory() != null) {
      bandwidthHistoryLines.add(
          descriptor.getDirreqWriteHistory().getLine());
    }
    if (descriptor.getDirreqReadHistory() != null) {
      bandwidthHistoryLines.add(
          descriptor.getDirreqReadHistory().getLine());
    }
    this.addExtraInfoDescriptorContents(descriptor.getDigestSha1Hex(),
        descriptor.getNickname(),
        descriptor.getFingerprint().toLowerCase(),
        descriptor.getPublishedMillis(), bandwidthHistoryLines);
  }

  /**
   * Close the relay descriptor database connection.
   */
  public void closeConnection() {

    /* Log stats about imported descriptors. */
    this.logger.info(String.format("Finished importing relay "
        + "descriptors: %d consensuses, %d network status entries, %d "
        + "votes, %d server descriptors, %d extra-info descriptors, %d "
        + "bandwidth history elements, and %d dirreq stats elements",
        rcsCount, rrsCount, rvsCount, rdsCount, resCount, rhsCount,
        rqsCount));

    /* Insert scheduled updates a second time, just in case the refresh
     * run has started since inserting them the first time in which case
     * it will miss the data inserted afterwards.  We cannot, however,
     * insert them only now, because if a Java execution fails at a random
     * point, we might have added data, but not the corresponding dates to
     * update statistics. */
    if (this.importIntoDatabase) {
      try {
        for (long dateMillis : this.scheduledUpdates) {
          this.psU.setDate(1, new java.sql.Date(dateMillis));
          this.psU.execute();
        }
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not add scheduled dates "
            + "for the next refresh run.", e);
      }
    }

    /* Commit any stragglers before closing. */
    if (this.conn != null) {
      try {
        this.csH.executeBatch();

        this.conn.commit();
      } catch (SQLException e)  {
        this.logger.log(Level.WARNING, "Could not commit final records "
            + "to database", e);
      }
      try {
        this.conn.close();
      } catch (SQLException e) {
        this.logger.log(Level.WARNING, "Could not close database "
            + "connection.", e);
      }
    }

    /* Close raw import files. */
    try {
      if (this.statusentryOut != null) {
        this.statusentryOut.write("\\.\n");
        this.statusentryOut.close();
      }
      if (this.descriptorOut != null) {
        this.descriptorOut.write("\\.\n");
        this.descriptorOut.close();
      }
      if (this.bwhistOut != null) {
        this.bwhistOut.write("\\.\n");
        this.bwhistOut.close();
      }
      if (this.consensusOut != null) {
        this.consensusOut.write("\\.\n");
        this.consensusOut.close();
      }
    } catch (IOException e) {
      this.logger.log(Level.WARNING, "Could not close one or more raw "
          + "database import files.", e);
    }
  }
}

