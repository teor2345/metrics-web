/* Copyright 2011, 2012 The Tor Project
 * See LICENSE for licensing information */
package org.torproject.metrics.web.status;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ConsensusHealthServlet extends HttpServlet {

  private static final long serialVersionUID = -5230032733057814869L;

  public void doGet(HttpServletRequest request,
      HttpServletResponse response) throws IOException,
      ServletException {

    /* Read file from disk and write it to response. */
    BufferedInputStream input = null;
    BufferedOutputStream output = null;
    try {
      File f = new File("/srv/metrics.torproject.org/ernie/website/"
          + "consensus-health.html");
      if (!f.exists()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
      }
      response.setContentType(this.getServletContext().getMimeType(f.getName()));
      response.setHeader("Content-Length", String.valueOf(
          f.length()));
      response.setHeader("Content-Disposition",
          "inline; filename=\"" + f.getName() + "\"");
      input = new BufferedInputStream(new FileInputStream(f),
          1024);
      output = new BufferedOutputStream(response.getOutputStream(), 1024);
      byte[] buffer = new byte[1024];
      int length;
      while ((length = input.read(buffer)) > 0) {
          output.write(buffer, 0, length);
      }
    } finally {
      if (output != null) {
        output.close();
      }
      if (input != null) {
        input.close();
      }
    }
  }
}
