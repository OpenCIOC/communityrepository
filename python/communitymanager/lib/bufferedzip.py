import time
import zipfile
import zlib
import binascii
import struct


# From http://stackoverflow.com/a/299830/108518
class BufferedZipFile(zipfile.ZipFile):
	""" Version of zipfile.ZipFile that can take a buffer to read from """

	def writebuffer(self, buffer, zinfo_or_arcname, compress_type=None):
		if not isinstance(zinfo_or_arcname, zipfile.ZipInfo):
			zinfo = zipfile.ZipInfo(
				filename=zinfo_or_arcname,
				date_time=time.localtime(time.time())[:6])

			zinfo.compress_type = self.compression
			zinfo.external_attr = 0600 << 16

		else:
			zinfo = zinfo_or_arcname

		if compress_type is not None:
			zinfo.compress_type = compress_type

		zinfo.file_size = file_size = 0
		zinfo.flag_bits = 0x00
		zinfo.header_offset = self.fp.tell()

		self._writecheck(zinfo)
		self._didModify = True

		zinfo.CRC = CRC = 0
		zinfo.compress_size = compress_size = 0
		self.fp.write(zinfo.FileHeader())
		if zinfo.compress_type == zipfile.ZIP_DEFLATED:
			cmpr = zlib.compressobj(zlib.Z_DEFAULT_COMPRESSION, zlib.DEFLATED, -15)
		else:
			cmpr = None

		while True:
			buf = buffer.read(1024 * 8)
			if not buf:
				break

			file_size = file_size + len(buf)
			CRC = binascii.crc32(buf, CRC) & 0xffffffff
			if cmpr:
				buf = cmpr.compress(buf)
				compress_size = compress_size + len(buf)

			self.fp.write(buf)

		if cmpr:
			buf = cmpr.flush()
			compress_size = compress_size + len(buf)
			self.fp.write(buf)
			zinfo.compress_size = compress_size
		else:
			zinfo.compress_size = file_size

		zinfo.CRC = CRC
		zinfo.file_size = file_size
		# Seek backwards and write CRC and file sizes
		position = self.fp.tell()
		self.fp.seek(zinfo.header_offset + 14, 0)
		self.fp.write(struct.pack("<LLL", zinfo.CRC, zinfo.compress_size, zinfo.file_size))
		self.fp.seek(position, 0)
		self.filelist.append(zinfo)
		self.NameToInfo[zinfo.filename] = zinfo
