## Gitlab Runners on demand

The 2 lambda functions in this repo manipulate the desired instances of a predefined ASG based on calls from Gitlab webhooks.

This is to allow occasional developers to have dedicated runners for their projects without the overhead of permanent runners.

To build the required ZIP files, you can simply run `make build` in the root of this repo.

I might get around to modularising the code & adding tests at some point if I find time.

The terraform directory is intended as an example only, it is not something to consider to be production-ready.

Nonetheless, it contains a working deployment of this solution with the required lambdas, API gateway & ASG with a launch configuration that builds a Gitlab runner on EC2, in Docker, using flatcar linux. YMMV.