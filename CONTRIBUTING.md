# How to Contribute

Thanks for your interest in contributing to vmclarity-tools-base! Here are a few general guidelines on contributing and
reporting bugs that we ask you to review. Following these guidelines helps to communicate that you respect the time of
the contributors managing and developing this open source project. In return, they should reciprocate that respect in
addressing your issue, assessing changes, and helping you finalize your pull requests. In that spirit of mutual respect,
we endeavor to review incoming issues and pull requests within 10 days, and will close any lingering issues or pull
requests after 60 days of inactivity.

Please note that all of your interactions in the project are subject to our [Code of Conduct](/CODE_OF_CONDUCT.md). This
includes creation of issues or pull requests, commenting on issues or pull requests, and extends to all interactions in
any real-time space e.g., Slack, Discord, etc.

## Table Of Contents

- [Troubleshooting and Debugging](#troubleshooting-and-debugging)
- [Reporting Issues](#reporting-issues)
- [Development](#development)
  - [Building vmclarity-tools-base Container](#building-vmclarity-tools-base-container)
- [Sending Pull Requests](#sending-pull-requests)
- [Other Ways to Contribute](#other-ways-to-contribute)

## Troubleshooting and Debugging

Please see the troubleshooting and debugging guide [here](/docs/troubleshooting.md).

## Reporting Issues

Before reporting a new issue, please ensure that the issue was not already reported or fixed by searching through our
[issues list](https://github.com/openclarity/vmclarity-tools-base/issues).

When creating a new issue, please be sure to include a **title and clear description**, as much relevant information as
possible, and, if possible, a test case.

**If you discover a security bug, please do not report it through GitHub. Instead, please see security procedures in
[SECURITY.md](/SECURITY.md).**

## Development

### Building vmclarity-tools-base Container

`make docker` can be used to build the vmclarity-tools-base container.

`make push-docker` is also provided as a shortcut for building and then
publishing the vmclarity-tools-base container to a registry. You can override the
destination registry like:

```
DOCKER_REGISTRY=docker.io/tehsmash make push-docker
```

You must be logged into the docker registry locally before using this target.

## Sending Pull Requests

Before sending a new pull request, take a look at existing pull requests and issues to see if the proposed change or fix
has been discussed in the past, or if the change was already implemented but not yet released.

We expect new pull requests to include tests for any affected behavior, and, as we follow semantic versioning, we may
reserve breaking changes until the next major version release.

## Other Ways to Contribute

We welcome anyone that wants to contribute to vmclarity-tools-base to triage and reply to open issues to help troubleshoot
and fix existing bugs. Here is what you can do:

- Help ensure that existing issues follows the recommendations from the _[Reporting Issues](#reporting-issues)_ section,
  providing feedback to the issue's author on what might be missing.
- Review and update the existing content of our [Wiki](https://github.com/openclarity/vmclarity-tools-base/wiki) with up-to-date
  instructions and code samples.
- Review existing pull requests, and testing patches against real existing applications that use vmclarity-tools-base.
- Write a test, or add a missing test case to an existing test.

Thanks again for your interest on contributing to vmclarity-tools-base!

:heart:
