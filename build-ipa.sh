#!/usr/bin/env bash
set -ex

TMPDIR=$(mktemp -d -p /var/tmp)
TMPDIR_RAMDISK=$(mktemp -d -p /var/tmp)

chmod 755 $TMPDIR
cd $TMPDIR
tar -xf /usr/share/rhosp-director-images/ironic-python-agent-latest.tar
cd $TMPDIR_RAMDISK
/usr/lib/dracut/skipcpio $TMPDIR/ironic-python-agent.initramfs | zcat | cpio -ivd

# $TMPDIR_RAMDISK ends up as "/" on the ramdisk and needs to be readable by more
# then just root
chmod 755 .

# NOTE(elfosardo) we could inject a list of packages that we want to add, based
# on what we download in the main image and call this part only if we actually
# have packages in the list.
# Also version tagging is something we should consider.
# And cookies.
rpm2cpio /tmp/packages/openstack-ironic-python-agent*.rpm | cpio -ivdum
rpm2cpio /tmp/packages/python3-ironic-python-agent*.rpm | cpio -ivdum
rpm2cpio /tmp/packages/python3-ironic-lib*.rpm | cpio -ivdum
find . 2>/dev/null | cpio -c -o | gzip -8  > /var/tmp/ironic-python-agent.initramfs
cp $TMPDIR/ironic-python-agent.kernel /var/tmp/
cd /var/tmp
ls -la
rm -fr $TMPDIR $TMPDIR_RAMDISK
