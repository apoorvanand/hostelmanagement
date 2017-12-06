// @flow
import React, { Component } from 'react';
import styled from 'styled-components';
import axios from 'axios';
import Select from '../shared/form/Select';
import Button from '../shared/Button';
import TextLink from '../shared/TextLink';

type State = {
  intent: string,
  isEditing: boolean,
  saveStatus: string,
  errorMessage: string,
};

type Props = {
  user: Object,
  draw: Object,
  is_editing: boolean,
};

const intentMapping = {
  off_campus: 'Off Campus',
  on_campus: 'On Campus',
  undeclared: 'Undeclared',
};

const Error = styled.p`
  color: #db6764;
`;

export default class IntentSelection extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    (this: any).handleChange = this.handleChange.bind(this);
    (this: any).handleSubmit = this.handleSubmit.bind(this);
    (this: any).toggleEdit = this.toggleEdit.bind(this);
  }

  // Initialize state
  state: State = {
    intent: this.props.user.intent,
    saveStatus: '',
    isEditing: this.props.is_editing || false,
    hasError: false,
    errorMessage: '',
  };
  props: Props;

  toggleEdit() {
    const { user } = this.props;
    this.setState({
      isEditing: !this.state.isEditing,
      intent: user.intent,
    });
  }

  handleChange(selected: string) {
    this.setState({
      intent: selected,
      saveStatus: '',
    });
  }

  handleSubmit() {
    const { user } = this.props;
    const { intent } = this.state;
    this.setState({
      saveStatus: 'saving',
    });
    return axios
      .patch(`/api/v1/users/${user.id}/intent`, {
        intent,
      })
      .then((response) => {
        const responseData = response.data;
        const { data } = responseData;
        user.intent = data.intent;
        this.setState({
          saveStatus: '',
          isEditing: false,
          errorMessage: '',
        });
      })
      .catch((error) => {
        const messageObj = error.response.data.msg;
        this.setState({
          saveStatus: '',
          errorMessage: messageObj ? messageObj.error : 'Something went wrong! Please try again',
        });
      });
  }

  render() {
    const { handleChange, handleSubmit, toggleEdit } = this;
    const { draw } = this.props;
    const { intent, isEditing, saveStatus, errorMessage } = this.state;
    return (
      <div>
        {errorMessage && <Error>{errorMessage}</Error>}
        {isEditing ? (
          <div>
            <Select
              items={intentMapping}
              currentValue={intent}
              onChange={handleChange}
              disabled={saveStatus !== ''}
            />
            <Button onClick={handleSubmit} disabled={saveStatus !== ''}>
              {saveStatus === '' && 'Submit intent'}
              {saveStatus === 'saving' && 'Saving...'}
              {saveStatus === 'saved' && 'Intent saved!'}
            </Button>{' '}
            <Button grey onClick={toggleEdit} disabled={saveStatus !== ''}>
              Cancel
            </Button>
          </div>
        ) : (
          <div>
            <p>
              <span>Your housing intent is {intentMapping[intent]}.</span>{' '}
              {draw.status === 'pre_lottery' && <TextLink onClick={toggleEdit}>Edit</TextLink>}
            </p>
          </div>
        )}
      </div>
    );
  }
}
