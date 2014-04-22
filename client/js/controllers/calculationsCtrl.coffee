window.CalculationsCtrl = ['$scope', '$http', ($scope, $http) ->
    $scope.cypherText = 'START n=node(*)\n' +
      'RETURN n.name'
    $scope.resultText = ''


    $scope.addRel = =>
      # add the relationship to the graph and to the db
      $http.post('/relationship', { Obj: $scope.object, Rel: $scope.relationship, Sub: $scope.subject })

    # call the rest api endpoint to get the data
    $scope.execCypher = =>
      # add the relationship to the graph and to the db
      $http.post('/graph/cypher', { query: $scope.cypherText }).success (data, status) =>
        $scope.resultText = data
]