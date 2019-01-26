{ stdenv, fetchurl, pkgconfig, autoreconfHook
, glib, gdk_pixbuf, gobject-introspection
, gtk-doc, docbook_xsl, xmlto, docbook_xml_dtd_412 }:

stdenv.mkDerivation rec {
  ver_maj = "0.7";
  ver_min = "7";
  name = "libnotify-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/libnotify/${ver_maj}/${name}.tar.xz";
    sha256 = "017wgq9n00hx39n0hm784zn18hl721hbaijda868cm96bcqwxd4w";
  };

  # disable tests as we don't need to depend on gtk+(2/3)
  configureFlags = [ "--disable-tests" "--enable-gtk-doc" "--enable-docbook-docs" ];

  XML_CATALOG_FILES = "${docbook_xsl}/xml/xsl/docbook/catalog.xml ${docbook_xml_dtd_412}/xml/dtd/docbook/catalog.xml";

  nativeBuildInputs = [ pkgconfig autoreconfHook gobject-introspection gtk-doc xmlto ];
  buildInputs = [ glib gdk_pixbuf ];

  meta = with stdenv.lib; {
    homepage = https://developer.gnome.org/notification-spec/;
    description = "A library that sends desktop notifications to a notification daemon";
    platforms = platforms.unix;
    license = licenses.lgpl21;
  };
}
