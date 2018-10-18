import React from "react";

class Playlist extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <section className="playlist">
        <a href="#">
          <i className="ion-ios-plus-outline" />
          New Playlist
        </a>
      </section>
    );
  }
}

export default Playlist;
