#!/bin/bash
# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#   PizzaFactory Project - Fix for PizzaFactory/Camino

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

if ! grep -Fq "${USER_ID}" /etc/passwd; then
    # current user is an arbitrary 
    # user (its uid is not in the 
    # container /etc/passwd). Let's fix that    
    sed -e "s/\${USER_ID}/${USER_ID}/g" \
        -e "s/\${GROUP_ID}/${GROUP_ID}/g" \
        -e "s/\${HOME}/\/home\/user/g" \
	/.passwd.template > /etc/passwd
    
    sed -e "s/\${USER_ID}/${USER_ID}/g" \
        -e "s/\${GROUP_ID}/${GROUP_ID}/g" \
        -e "s/\${HOME}/\/home\/user/g" \
	/.group.template > /etc/group
fi

exec "$@"
