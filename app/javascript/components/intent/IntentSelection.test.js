import React from 'react';
import { mount } from 'enzyme';
import sinon from 'sinon';
import axios from 'axios';
import IntentSelection from './IntentSelection';
import Select from '../shared/form/Select';
import Button from '../shared/Button';
import TextLink from '../shared/TextLink';

const intentMapping = {
  off_campus: 'Off Campus',
  on_campus: 'On Campus',
  undeclared: 'Undeclared',
};

describe('IntentSelection', () => {
  let props;
  let state;
  let mounted;
  const intentSelection = () => {
    if (!mounted) {
      mounted = mount(<IntentSelection {...props} />);
    }
    return mounted;
  };

  // Before each test reset props and remount component
  beforeEach(() => {
    props = {
      user: {
        intent: 'off_campus',
      },
      draw: {},
      is_editing: undefined,
    };
    mounted = undefined;
  });

  // Tests go here
  it('always renders a div', () => {
    const divs = intentSelection().find('div');
    expect(divs.length).toBeGreaterThan(0);
  });

  describe('when draw status is pre_lottery', () => {
    beforeEach(() => {
      props.draw = {
        status: 'pre_lottery',
      };
    });

    describe('when is_editing props is passed', () => {
      describe('when is_editing props is true', () => {
        beforeEach(() => {
          props.is_editing = true;
        });
        it('sets state isEditing to true', () => {
          expect(intentSelection().state('isEditing')).toBe(true);
        });
      });

      describe('when is_editing props is false', () => {
        beforeEach(() => {
          props.is_editing = false;
          it('sets state isEditing to false', () => {
            expect(intentSelection().state('isEditing')).toBe(false);
          });
        });
      });
    });

    describe('when is_editing props is undefined', () => {
      it('sets state isEditing to false', () => {
        expect(intentSelection().state('isEditing')).toBe(false);
      });
    });

    describe('when isEditing state is true', () => {
      beforeEach(() => {
        intentSelection().setState({ isEditing: true });
      });

      it('always renders a Select', () => {
        expect(intentSelection().find(Select).length).toBe(1);
      });

      it('always renders 2 Buttons', () => {
        expect(intentSelection().find(Button).length).toBe(2);
      });
    });

    describe('when isEditing state is false', () => {
      beforeEach(() => {
        intentSelection().setState({ isEditing: false });
      });

      it('always renders a p', () => {
        expect(intentSelection().find('p').length).toBe(1);
      });

      it('displays current intent', () => {
        const intentMessage = intentSelection()
          .find('p span')
          .text();
        const currentIntent = intentSelection().state('intent');
        expect(intentMessage).toBe(`Your housing intent is ${intentMapping[currentIntent]}.`);
      });

      it('always renders a TextLink', () => {
        expect(intentSelection().find(TextLink).length).toBe(1);
      });
    });

    describe('when errorMessage state is true', () => {
      beforeEach(() => {
        intentSelection().setState({ errorMessage: 'Error' });
      });

      it('displays error message', () => {
        const errorMessage = intentSelection()
          .find('p')
          .first()
          .text();
        expect(errorMessage).toBe('Error');
      });
    });

    describe('when user toggles edit TextLink', () => {
      it('updates isEditing state to true', () => {
        intentSelection()
          .find(TextLink)
          .simulate('click');
        expect(intentSelection().state('isEditing')).toBe(true);
      });
    });

    describe('when user is editing intent', () => {
      beforeEach(() => {
        props.is_editing = true;
      });

      describe('when the user changes intent', () => {
        it('updates intent state', () => {
          intentSelection()
            .find('select')
            .simulate('change', { target: { value: 'on_campus' } });
          expect(intentSelection().state('intent')).toBe('on_campus');
        });
      });

      describe('when the user clicks cancel', () => {
        it('resets intent and isEditing state', () => {
          intentSelection().setState({ intent: 'undeclared' });
          intentSelection()
            .find(Button)
            .last()
            .simulate('click');
          expect(intentSelection().state('isEditing')).toBe(false);
          expect(intentSelection().state('intent')).toBe(props.user.intent);
        });
      });

      describe('when user submits intent', () => {
        it('updates user and intent state', () => {
          const fakeResponse = {
            data: {
              data: {
                intent: 'on_campus',
              },
            },
          };
          const promise = Promise.resolve(fakeResponse);
          sinon.stub(axios, 'patch').callsFake(() => promise);
          intentSelection()
            .find('select')
            .simulate('change', { target: { value: 'on_campus' } });
          intentSelection()
            .find(Button)
            .first()
            .simulate('click');
          return promise.then(() => {
            expect(intentSelection().prop('user').intent).toBe('on_campus');
            expect(intentSelection().state('intent')).toBe('on_campus');
            expect(intentSelection().state('isEditing')).toBe(false);
          });
        });
      });
    });
  });
});
