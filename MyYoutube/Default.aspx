<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="MyYoutube._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="modal" id="UserModal">
        <div class="modal-dialog">
            <div class="modal-content">

                <!-- Modal Header -->
                <div class="modal-header">
                    <h4 class="modal-title">User Name: <span id="currentUser"></span></h4>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>

                <!-- Modal body -->
                <div class="modal-body">
                    <p id="currentUserType"></p>
                </div>
                <hr />

                <div class="modal-header">
                    <h4 class="modal-title">Uploaded Videos</h4>
                </div>

                <div class="modal-body">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Upload Time</th>
                            </tr>
                        </thead>
                        <tbody id="UploadedList">
                        </tbody>


                    </table>
                </div>



                <!-- Modal footer -->
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-9 ">
            <div id="tv_container" style="">
                <video height="375px" id="PlayingVideo">
                </video>
            </div>

            <h2 id="videoTitle">Video Title</h2>

            <hr />
            <div class="panel-group" id="accordion">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title ">
                            <a data-toggle="collapse" data-parent="#accordion" href="#collapse1">About video</a>
                        </h4>
                    </div>
                    <div id="collapse1" class="panel-collapse collapse ">
                        <div class="panel-body">

                            <div class="Details">
                                <p>
                                    Uploaded Date : 
                                <span class="small" id="videodate"></span>
                                </p>
                                <p>
                                    Uploaded User : 
                                <span class="small" id="VideoUser"></span>
                                </p>
                                <p>
                                    size : 
                                <span class="small" id="videosize"></span>
                                </p>
                                <p>
                                    Description : 
                                <span class="small" id="videDescription"></span>
                                </p>

                            </div>
                        </div>
                    </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#collapse2" id="CommentTag">Comments</a>
                        </h4>
                    </div>
                    <div id="collapse2" class="panel-collapse collapse">
                        <div class="panel-body">

                            <div class="actionBox">
                                <ul class="commentList" id="result">
                                </ul>

                                <div class="form-group">
                                    <textarea class="form-control" placeholder="Your comments"></textarea>
                                </div>
                                <div class="form-group">
                                    <button class="btn btn-default" style="width: 10%">Add</button>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>

        <div class="col-sm-3" <%--style="background-color: #ddd; border-radius: 4px; border: 1px solid transparent; padding-left: 23px; padding-top: 20px; height: 100%"--%>>
            <div id="loadvideo"></div>
        </div>

    </div>

    <script>
        if (!localStorage['done']) {
            localStorage['done'] = 'yes';
            pageLoad();
        }


        document.addEventListener('DOMContentLoaded', loadAllVideos);
        function loadAllVideos() {

            const xhr = new XMLHttpRequest();
            xhr.open('GET', 'https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/videos', true);
            xhr.onload = function () {
                var responseV = JSON.parse(this.responseText);
                let output = '';
                responseV.forEach(function (post) {


                    output += `                               
                               <p style="border:5px"> <video onclick="playVideo(event)" id="vl" class="mr-3 mt-3 rounded-circle" >
                                    <source src="${post.url}" type="video/MP4" id="${post.id}"  class="VideoList"  />

                    <div class="media-body">
                    <h4 id="vtitle">${post.title}</h4> <span id="vdate"><small><i class=>Posted on ${post.uploadedAt}</i></small><span>
                    
                </div><hr/>
                                 </video></p>

                `

                });
                document.querySelector('#loadvideo').innerHTML = output;




            }

            xhr.send();

        }
        function loadVideoDetailsById(Id) {
            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/videos/' + Id)
                .then(response => response.json())
                .then(function (json) {
                    document.getElementById("videoTitle").innerHTML = json.title;
                    document.getElementById("videodate").innerHTML = json.uploadedAt;
                    document.getElementById("videDescription").innerHTML = json.description;

                    document.getElementById("videosize").innerHTML = json.size;
                    showUserName(json.userId);

                });

        }
        //function loadVideoCommentsById(id) {
        //    let output = '';
        //    // var y;
        //    fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/comments')
        //        .then(response => response.json())
        //        .then(function (json) {
        //            json.forEach(function (comment) {
        //                if (comment.videoId == id) {

        //                    output += `
        //                        <li>
        //                            <div class="Uid" style="font-weight:bold">
        //                                <span name="${comment.userId}" ></span> 
        //                            </div>
        //                            <div class="commentText">
        //                                <p class="">${comment.body}</p>
        //                                <span class="date sub-text">${comment.date}</span>

        //                            </div>
        //                        </li>
        //        `

        //                }

        //                document.querySelector('#result').innerHTML = output;

        //            })

        //        });


        //}
        function loadVideoCommentsById(id) {
            return fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/comments')
                .then(response => response.json())
                .then(json =>
                    Promise.all(
                        // filter only the comments that match `id`
                        json.filter(comment => comment.videoId == id)
                            // get the username for each comment
                            .map(comment => fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/users/' + comment.userId)
                                .then(response => response.json())
                                .then(json => ({ username: json.name, comment }))
                            )
                    )
                )
            // data will be an array like [{username, comment}, {username, comment} ...]
            
                .then(data => data.map(({ username, comment }) => `
        <li>
            <div class="Uid">
                <span ><b>` + username + `</b>:</span> 
            </div>
            <div class="commentText">
                <p class="">${comment.body}</p>
                <span class="date sub-text">${comment.date}</span>
            </div>
        </li>
        `
                ).join(''))
                .then(output => document.querySelector('#result').innerHTML = output);
          
        }

        function showUser(event) {
            var Id = event.target.id;
            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/users/' + Id)
                .then(response => response.json())
                .then(function (user) {
                    document.getElementById("ShowName").innerHTML = user.name;
                    document.getElementById("currentUser").innerHTML = user.name;
                    document.getElementById("currentUserType").innerHTML = user.type;

                });
            LoadUserVideos(Id);

        }

        function loadUsers() {
            let output = '';
            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/users')
                .then(response => response.json())
                .then(function (json) {
                    json.forEach(function (user) {

                        output += `
                                   <a class="dropdown-item" onclick="showUser(event)" href="#" data-toggle="modal" data-target="#UserModal"><p id="${user.id}">${user.name}</p> </a>
                `
                    })
                    document.querySelector('#dropdown').innerHTML = output;


                });
        }

        function showUserName(id) {

            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/users/' + id)
                .then(response => response.json())
                .then(function (json) {



                    document.getElementById('VideoUser').innerHTML = json.name;




                });
        }



        function LoadUserVideos(id) {

            let output = '';
            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/videos/')
                .then(response => response.json())
                .then(function (json) {
                    json.forEach(function (video) {
                        if (video.userId == id) {

                            output += `
                            <tr> <td>${video.title}</td><td>${video.uploadedAt}></td></tr>
                `
                        }
                        document.querySelector('#UploadedList').innerHTML = output;
                    })
                });
        }



        function playVideo(event) {

            var x = event.target.querySelector('source');
            var SelectedId = x.id;
            var selected = x.src;
            var video = document.getElementById('PlayingVideo');
            var changeUrl = document.getElementById("PlayingVideo").hasChildNodes();
            while (video.firstChild) {
                video.removeChild(video.firstChild);
            }
            video.load();
            loadVideoDetailsById(SelectedId);
            loadVideoCommentsById(SelectedId);
            var source = document.createElement('source');
            source.setAttribute('src', selected);
            video.appendChild(source);
            video.setAttribute("controls", "");
            video.setAttribute("style", "cursor: pointer;");
            video.play();
        }

        function pageLoad() {

            fetch('https://my-json-server.typicode.com/apollo-motorhomes/youtube-test/videos/1')
                .then(response => response.json())
                .then(function (videoUrl) {
                    var video = document.getElementById('PlayingVideo');
                    var source = document.createElement('source');
                    source.setAttribute('src', videoUrl.url);
                    video.appendChild(source);
                    video.setAttribute("controls", "");
                    video.setAttribute("style", "cursor: pointer;");
                    loadVideoDetailsById(videoUrl.id);
                    loadVideoCommentsById(videoUrl.id);

                });
        }



    </script>

</asp:Content>
