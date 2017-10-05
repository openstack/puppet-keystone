# Examples of the new interface to user, project (tenant), and
# user_role.
#
# The new interface does not rely on a unique title scheme and offers
# the possibility to pass required arguments as parameters.  Old
# interface with everything defined in the title is still supported,
# but the parsing is more consistent and less error prone (on the
# coding side).  Puppet will find matching resource irrespective of
# how you create it.

# For user you have those choices
keystone_user { 'user_one':
  ensure => present,
  domain => 'domain_one',
}

# is identical to

keystone_user { 'user_one::domain_one': ensure => present }

# Note, that parameter override title paring.  So:
keystone_user { 'user_one::domain_two':
  ensure => present,
  domain => 'domain_one'
}

# will create the user in the domain_one, not domain_two.

# This led to the meaningless title feature.  This can be helpful for
# manifest/hiera created by another program for instance, where the
# title could be some random id:

keystone_user { 'meanlinglesstitle':
  ensure => present,
  user   => 'user_one',
  domain => 'domain_one'
}

# This works for user, project and, with a twist, for user_role, where
# the title must always have some form.  See below.

# For project:

keystone_tenant { 'project_one':
  ensure => present,
  domain => 'domain_one'
}

# is identical to

keystone_tenant { 'project_one::domain_one': ensure => present }

# For user_role:

# 1: for associating a role to an user in a project scope.
keystone_user_role { 'user_one::project_one':
  ensure         => present,
  user_domain    => 'domain_one',
  project_domain => 'domain_two',
  roles          => ['admin']
}

# all the way to
keystone_user_role { 'user_one::domain_one@project_one::domain_two':
  ensure => present,
  roles  => ['admin']
}
# and all combinations in between.

# Note that parameter override the title parsing, so:
keystone_user_role { 'user_one::domain_one@project_one::domain_one':
  ensure         => present,
  project_domain => 'domain_two',
  roles          => ['admin']
}

# will match the project project_one::domain_two, not
# project_one::domain_one.  It is also true for keystone_user and
# keystone_tenant.

# You cannot define:
keystone_user_role { 'user_one':
  ensure         => present,
  user_domain    => 'domain_one',
  project        => 'project_one',
  project_domain => 'domain_two',
  roles          => ['admin']
}

# this will trigger an error.  You need the '::'

# 2: for associating a role to an user in a domain scope.
keystone_user_role { 'user_one@::domain':
  ensure      => present,
  user_domain => 'domain_one',
  roles       => ['admin']
}

# is identical to
keystone_user_role { 'user_one::domain_one@::domain_one':
  ensure => present,
  roles  => ['admin']
}

# But, you cannot define:
keystone_user_role { 'meaningless_title':
  ensure      => present,
  user        => 'user_one',
  user_domain => 'domain_one',
  domain      => 'domain_one',
  roles       => ['admin']
}

# this will trigger an error, you need the '::@'

# But, there is a way to have meaningless title for user_role.

# 1: user role to project.
keystone_user_role { 'meaningless::meaningless':
  ensure         => present,
  user           => 'user_one',
  user_domain    => 'domain_one',
  project        => 'project_one',
  project_domain => 'domain_one',
  roles          => ['admin']
}

# 2: user role to domain
keystone_user_role { 'meaningless::@meaningless':
  ensure      => present,
  user        => 'user_one',
  user_domain => 'domain_one',
  domain      => 'project_one',
  roles       => ['admin']
}

# Finally it should be noted that specifying an domain and a project
# scope at the same time is an error.
keystone_user_role { 'user_one@::domain_one':
  ensure         => present,
  user_domain    => 'domain_one',
  project        => 'project_one',
  project_domain => 'domain_two',
  roles          => ['admin']
}
# is an error, and will trigger one.


# NOTE: for the all examples above to work you have to define:
keystone_domain { 'domain_one':
  ensure => present
}

keystone_domain { 'domain_two':
  ensure => present
}
