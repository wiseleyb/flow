# THIS IS NOT PRODUCTION READY YET - STILL WIP

# Flow
This is a utility you can use for typical Github/Pivotal development process to simplify all the hoops we generally need to jump through.

## Assumptions
You're using Pivotal and your dev process goes something like this:

1. start a story
2. checkout a branch
3. do some work
4. push the branch
5. mark the story finished
6. merge the story to master
7. delete the branch
7. merge the story to staging
8. mark the branch delivered
9. return to master and repeat

## Setup
You need to add this to your .bash_profile or, if you're using [rbenv-vars](https://github.com/rbenv/rbenv-vars) just loose the "export" and fill in.

    export PIVOTAL_USERNAME=Name
    export PIVOTAL_EMAIL=email@email.com
    export PIVOTAL_PASSWORD=super-secret-password
    export PIVOTAL_TOKEN=token-found-on-github-profile-page
    export PIVOTAL_PROJECT_ID=found-in-url

## Usage
Using this gem you'd do something like this:

1. flow start
	* would list all unstarted projects
	* ask for a point estimate if it's not set
	* mark it started
	* checkout a branch "{story_type}/{name}-{pivotal-id}"
2. do work
3. get add -p
4. flow finish
	* creates a commit message based on Pivotal story
	* adds link to Pivotal story
	* puts you into edit mode for the commit message
5. flow push
	* pushes the branch up to origin {branch-name}
6. people review - you get a +1
7. flow merge_master
	* checks out master
	* pulls from origin
	* check out branch
	* rebase master -i
	* git push origin branch-name --force
	* checks out master
	* merge branch to master
	* git push origin master
	* mark story finished
8. flow merge_staging
	* checks out master
	* pull from origin
	* checks out staging
	* pull from origin staging
	* merge master
	* git push origin staging
	* git checkout master
	* marks story delivered

## TODO

* specs
* confirm git commands do what's expected and bail if something goes south (like a merge conflict)
* add a simple plugin archtecture to make it trivial base your dev shops process off simple steps
* add option for specs runs, rubocop, linters, at various stages
* integrate things like code-ship and check builds
* add ability to do pull requests
