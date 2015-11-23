


Name:           pixman
Version:        0.26.2
Release:        1%{?dist}
Summary:        Pixel manipulation library

Vendor:		Continuum Analytics, Inc.
Packager:	build@continuum.io

Group:          System Environment/Libraries
License:        MIT
URL:            http://cgit.freedesktop.org/pixman/

Source0:        http://xorg.freedesktop.org/archive/individual/lib/%{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  automake autoconf libtool pkgconfig


%description
Pixman is a pixel manipulation library for X and cairo.


%package devel
Summary: Pixel manipulation library development package
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}
Requires: pkgconfig

%description devel
Development library for pixman.


%prep
%setup -q


%build
%configure --disable-static
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
rm -f $RPM_BUILD_ROOT%{_libdir}/*.la


%clean
rm -rf $RPM_BUILD_ROOT


%post -p /sbin/ldconfig


%postun -p /sbin/ldconfig


%files
%defattr(-,root,root,-)
%{_libdir}/libpixman-1*.so.*


%files devel
%defattr(-,root,root,-)
%dir %{_includedir}/pixman-1
%{_includedir}/pixman-1/pixman.h
%{_includedir}/pixman-1/pixman-version.h
%{_libdir}/libpixman-1*.so
%{_libdir}/pkgconfig/pixman-1.pc


%changelog
