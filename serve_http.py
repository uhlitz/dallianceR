#! /usr/bin/env python

# Standard library imports.
from SocketServer import ThreadingMixIn
import BaseHTTPServer
import SimpleHTTPServer
import sys
import json
import os
from os.path import (join, exists, dirname, abspath, isabs, sep, walk, splitext,
    isdir, basename, expanduser, split, splitdrive)
from os import makedirs, unlink, getcwd, chdir, curdir, pardir, rename, fstat
from shutil import copyfileobj, copytree
import glob
from zipfile import ZipFile
from urlparse import urlparse, parse_qs
from urllib import urlopen, quote, unquote
from posixpath import normpath
from cStringIO import StringIO
import re
import ConfigParser
import cgi
import threading
import socket
import errno

DATA_DIR = getcwd() # join(expanduser('~'), APP_NAME)

class ThreadingHTTPServer(ThreadingMixIn, BaseHTTPServer.HTTPServer):
    pass


class RequestHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    """ Handler to handle POST requests for actions.
    """

    serve_path = DATA_DIR

    def do_GET(self):
        """ Overridden to handle HTTP Range requests. """
        self.range_from, self.range_to = self._get_range_header()
        if self.range_from is None:
            # nothing to do here
            return SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)
        print 'range request', self.range_from, self.range_to
        f = self.send_range_head()
        if f:
            self.copy_file_range(f, self.wfile)
            f.close()

    def copy_file_range(self, in_file, out_file):
        """ Copy only the range in self.range_from/to. """
        in_file.seek(self.range_from)
        # Add 1 because the range is inclusive
        left_to_copy = 1 + self.range_to - self.range_from
        buf_length = 64*1024
        bytes_copied = 0
        while bytes_copied < left_to_copy:
            read_buf = in_file.read(min(buf_length, left_to_copy))
            if len(read_buf) == 0:
                break
            out_file.write(read_buf)
            bytes_copied += len(read_buf)
        return bytes_copied

    def send_range_head(self):
        """Common code for GET and HEAD commands.

        This sends the response code and MIME headers.

        Return value is either a file object (which has to be copied
        to the outputfile by the caller unless the command was HEAD,
        and must be closed by the caller under all circumstances), or
        None, in which case the caller has nothing further to do.

        """
        path = self.translate_path(self.path)
        f = None
        ctype = self.guess_type(path)
        try:
            # Always read in binary mode. Opening files in text mode may cause
            # newline translations, making the actual size of the content
            # transmitted *less* than the content-length!
            f = open(path, 'rb')
        except IOError:
            self.send_error(404, "File not found")
            return None

        if self.range_from is None:
            self.send_response(200)
        else:
            self.send_response(206)

        self.send_header("Content-type", ctype)
        fs = fstat(f.fileno())
        file_size = fs.st_size
        if self.range_from is not None:
            if self.range_to is None or self.range_to >= file_size:
                self.range_to = file_size-1
            self.send_header("Content-Range",
                             "bytes %d-%d/%d" % (self.range_from,
                                                 self.range_to,
                                                 file_size))
            # Add 1 because ranges are inclusive
            self.send_header("Content-Length", 
                             (1 + self.range_to - self.range_from))
        else:
            self.send_header("Content-Length", str(file_size))
        self.send_header("Last-Modified", self.date_time_string(fs.st_mtime))
        self.end_headers()
        return f

    def translate_path(self, path):
        """ Override to handle redirects.
        """
        path = path.split('?',1)[0]
        path = path.split('#',1)[0]
        path = normpath(unquote(path))
        words = path.split('/')
        words = filter(None, words)
        path = self.serve_path
        for word in words:
            drive, word = splitdrive(word)
            head, word = split(word)
            if word in (curdir, pardir): continue
            path = join(path, word)
        return path

    # Private interface ######################################################

    def _get_range_header(self):
        """ Returns request Range start and end if specified.
        If Range header is not specified returns (None, None)
        """
        range_header = self.headers.getheader("Range")
        if range_header is None:
            return (None, None)
        if not range_header.startswith("bytes="):
            print "Not implemented: parsing header Range: %s" % range_header
            return (None, None)
        regex = re.compile(r"^bytes=(\d+)\-(\d+)?")
        rangething = regex.search(range_header)
        if rangething:
            from_val = int(rangething.group(1))
            if rangething.group(2) is not None:
                return (from_val, int(rangething.group(2)))
            else:
                return (from_val, None)
        else:
            print 'CANNOT PARSE RANGE HEADER:', range_header
            return (None, None)


def get_server(port=8000, next_attempts=0, serve_path=None):
    Handler = RequestHandler
    if serve_path:
        Handler.serve_path = serve_path
    while next_attempts >= 0:
        try:
            httpd = ThreadingHTTPServer(("", port), Handler)
            return httpd
        except socket.error as e:
            if e.errno == errno.EADDRINUSE:
                next_attempts -= 1
                port += 1
            else:
                raise

def main(args=None):
    if args is None:
        args = sys.argv[1:]

    PORT = 8000
    if len(args)>0:
        PORT = int(args[-1])
    serve_path = DATA_DIR
    if len(args) > 1:
        serve_path = abspath(args[-2])

    httpd = get_server(port=PORT, serve_path=serve_path)

    print "serving at port", PORT
    httpd.serve_forever()

if __name__ == "__main__" :
    main()
