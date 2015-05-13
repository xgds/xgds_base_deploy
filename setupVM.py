#! /usr/bin/env python
"""
This script will configure a VM using puppet and (possibly) vagrant.  You can specify whether you
want a development or production setup.

For a development system vagrant will be used to run your dev VM with VirtualBox.  Run
this script in the directory on the *host* where you want the xGDS code to be checked out.

On a production server, we assume you have an existing Ubuntu 14.04 server installation and
this script is running in the home directory of the user that is hosting the xGDS deployment
(specify with --xgdsUser).
"""

import os
from os.path import expanduser
from subprocess import STDOUT, check_call

def installPuppet():
    check_call(['curl', '-o', '/tmp/puppetlabs-release-jessie.deb',
                'https://apt.puppetlabs.com/puppetlabs-release-jessie.deb'], stdout=open(os.devnull,'wb'), stderr=STDOUT)
    check_call(["sudo", "dpkg", "-i", "/tmp/puppetlabs-release-jessie.deb"], stdout=open(os.devnull,'wb'), stderr=STDOUT)
    print "Running apt-get update..."
    check_call(["sudo", "apt-get", "update"], stdout=open(os.devnull,'wb'))
    print "Installing puppet..."
    check_call(["sudo", "apt-get", "install", "puppet"])


def checkoutPuppetConfig(site):
    check_call(['pip', 'install', 'GitPython'], stdout=open(os.devnull,'wb'))
    import git
    if not os.path.exists("%s/puppet" % expanduser("~")):
        os.mkdir("%s/puppet" % expanduser("~"))
        repo = git.Repo.clone_from("https://babelfish.arc.nasa.gov/git/xgds_base_deploy",
                                   "%s/puppet/xgds_base_deploy" % expanduser("~"), branch='master')
        repo = git.Repo.clone_from("https://babelfish.arc.nasa.gov/git/xgds_%s_deploy" % site,
                                   "%s/puppet/xgds_%s_deploy" % (expanduser("~"),site),  branch='master')
    else:
        print "Puppet dir already exists. Not changing existing config"


def setupPuppetFacts(opts):
    if not os.path.exists("%s/puppet/xgds_base_deploy/modules/facts/facts.d" % expanduser("~")):
        os.makedirs("%s/puppet/xgds_base_deploy/modules/facts/facts.d" % expanduser("~"))
    f = open("%s/puppet/xgds_base_deploy/modules/facts/facts.d/facts.json" % expanduser("~"), "w")

    if opts.development:  # Setup file for development environment
        factString = """
        {"user":"%s",
        "dev_instance":true
        }""" % opts.xgdsUser

    if opts.production:
        factString = """
        {"user":"%s",
        "dev_instance":false
        }""" % opts.xgdsUser

    f.write(factString)
    f.close()


def runPuppet(site):
    print "\n === Running Puppet ==="
    check_call(["sudo", "puppet", "apply", "--modulepath", "%s/puppet/xgds_base_deploy/modules" % expanduser("~"),
                "%s/puppet/xgds_base_deploy/manifests/base.pp" % expanduser("~")])
    check_call(["sudo", "puppet", "apply", "--modulepath",
                "%s/puppet/xgds_%s_deploy/modules:%s/puppet/xgds_base_deploy/modules" % (expanduser("~"), site, expanduser("~")),
                "%s/puppet/xgds_%s_deploy/manifests/base.pp" % (expanduser("~"), site)])
    check_call(["sudo", "puppet", "apply", "--modulepath",
                "%s/puppet/xgds_%s_deploy/modules:%s/puppet/xgds_base_deploy/modules" % (expanduser("~"), site, expanduser("~")),
                "%s/puppet/xgds_%s_deploy/manifests/site.pp" % (expanduser("~"), site)])


def main():
    import optparse
    parser = optparse.OptionParser('usage: %prog --development|--production --siteName <xgdsSite>\n' + __doc__)
    parser.add_option('-d', '--development',
                      action="store_true", default=False,
                      help='Setup development VM environment with puppet')
    parser.add_option('-p', '--production',
                      action="store_true", default=False,
                      help='Setup production VM environment with puppet')
    parser.add_option('-u', '--xgdsUser',
                      type="string", default="vagrant",
                      help='Username for homedir where xGDS lives')
    parser.add_option('-s', '--siteName',
                      type="string", help='Name of xGDS site to deploy')
    opts, args = parser.parse_args()
    if args:
        parser.error('expected no args')
    if not opts.development and not opts.production:
        parser.error('you must specify either the --development or --production option')
    if  opts.development and opts.production:
        parser.error('you must specify only ONE of --development or --production')
    if not opts.siteName:
        parser.error('you must specify the name of an xGDS site to deploy.')

    if opts.development:
        vmType = "development"
    if opts.production:
        vmType = "production"

    print "Deploying an xGDS %s VM..." % vmType

    installPuppet()
    checkoutPuppetConfig(opts.siteName)
    setupPuppetFacts(opts)
    runPuppet(opts.siteName)

if __name__ == '__main__':
    main()
