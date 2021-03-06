# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7} )

DISTUTILS_USE_SETUPTOOLS="rdepend"
inherit distutils-r1 systemd

DESCRIPTION="Automatically create, prune and verify backups with borgbackup"
HOMEPAGE="https://torsion.org/borgmatic/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="${PYTHON_DEPS}
	dev-python/colorama[${PYTHON_USEDEP}]
	>=dev-python/pykwalify-1.6.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	<dev-python/ruamel-yaml-0.17.0"[${PYTHON_USEDEP}]
RDEPEND="${DEPEND}
	app-backup/borgbackup"
BDEPEND="test? (
		${DEPEND}
		dev-python/flexmock[${PYTHON_USEDEP}]
	)"

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.1-systemd_service_bin_path.patch
	"${FILESDIR}"/${PN}-1.5.1-no_test_coverage.patch
)

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# Unlike the other two test files in integration/commands, which use the
	# relevant modules' respective APIs, test_borgmatic.py tries to call the
	# 'borgmatic' executable - which has not even been created by now.
	# Seeing as the only test run from this file as of 2020-03-25 is the
	# parsing of contents of 'borgmatic --version', just skip it for now.
	rm -f "${S}"/tests/integration/commands/test_borgmatic.py
}

src_install() {
	distutils-r1_src_install
	systemd_dounit sample/systemd/borgmatic.{service,timer}
	keepdir /etc/borgmatic
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		elog "To generate a sample configuration file, run:"
		elog "    generate-borgmatic-config"
	else
		elog "To upgrade your configuration file to the current version, run:"
		elog "    upgrade-borgmatic-config"
	fi
	elog
	elog "Systemd users wishing to periodically run borgmatic can use the provided timer and service units."
}
